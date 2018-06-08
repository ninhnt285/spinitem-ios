//
//  PreviewViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/10/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    var images: [SPImage] = []
    
    var previewImageView: PreviewView!
    var closeButton: UIButton!
    
    var canSaveImage: Bool = false
    var isSaving: Bool = false
    var savedImage: Int = 0
    var saveButton: UIButton!
    var savingIndicatorView: UIActivityIndicatorView!
    var savingLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(previewImages: [SPImage]) {
        super.init(nibName: nil, bundle: nil)
        self.images = previewImages
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        previewImageView = PreviewView(images: [])
        view.addSubview(previewImageView)
        
        saveButton = UIButton()
        view.addSubview(saveButton)
        
        closeButton = UIButton()
        view.addSubview(closeButton)
        
        savingLabel = UILabel()
        view.addSubview(savingLabel)
        
        savingIndicatorView = UIActivityIndicatorView()
        view.addSubview(savingIndicatorView)
    }
    
    func configureSubviews() {
        if !canSaveImage {
            saveButton.isHidden = true
        }
        saveButton.setTitle("Save", for: UIControlState.normal)
        saveButton.addTarget(self, action: #selector(handleSave(_:)), for: UIControlEvents.touchUpInside)
        
        closeButton.setTitle("Close", for: UIControlState.normal)
        closeButton.addTarget(self, action: #selector(handleClose(_:)), for: UIControlEvents.touchUpInside)
        
        savingIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        savingIndicatorView.hidesWhenStopped = true
        savingIndicatorView.stopAnimating()
        
        savingLabel.textColor = UIColor.green
        savingLabel.text = "Saving: 0%"
        savingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        savingLabel.isHidden = true
        savingLabel.textAlignment = NSTextAlignment.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load images data if needed
        var totalProcessed = 0
        for image in images {
            image.loadImageDataFromServer(completion: { (err) in
                totalProcessed += 1
                if (totalProcessed == self.images.count) {
                    DispatchQueue.main.async {
                        self.updatePreviewImages()
                    }
                }
            })
        }
    }
    
    func updatePreviewImages() {
        var viewableImages = [UIImage]()
        for image in self.images {
            let viewableImage = UIImage(data: image.fileData!)
            viewableImages.append(viewableImage!)
        }
        self.previewImageView.images = viewableImages
    }
    
    override func viewWillLayoutSubviews() {
        let screen = UIScreen.main.bounds
        
        previewImageView.frame = screen
        previewImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        if (images.count > 0) {
            saveButton.frame.size = saveButton.sizeThatFits(CGSize(width: screen.width, height: screen.height))
            saveButton.frame.origin = CGPoint(x: 10, y: 25)
        }
        
        closeButton.frame.size = closeButton.sizeThatFits(CGSize(width: screen.width, height: screen.height))
        closeButton.frame.origin = CGPoint(x: screen.width - closeButton.frame.width - 10, y: 25)
        
        savingIndicatorView.frame.size = savingIndicatorView.sizeThatFits(screen.size)
        savingIndicatorView.center = view.center
        
        let savingLabelSize = savingLabel.sizeThatFits(screen.size)
        savingLabel.frame.size = CGSize(width: screen.width - 24, height: savingLabelSize.height)
        savingLabel.center = CGPoint(x: savingIndicatorView.center.x, y: savingIndicatorView.center.y + savingLabelSize.height + 24)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // Handlers
    @objc func handleClose(_ sender: UIButton?) {
        if !isSaving {
            if canSaveImage {
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleSave(_ sender: UIButton) {
        if (self.images.count == 0) {
            return
        }
        
        isSaving = true
        savingIndicatorView.startAnimating()
        savingLabel.isHidden = false
        
        // Create Item first
        let item = SPItem()
        item.addToServer { (err) in
            if err != nil {
                print("Can not create new item: \(err?.localizedDescription ?? "Unknown error")")
                return
            }
            // Only upload 1 image in the same time
            self.saveImage(index: 0, item: item)
        }
    }
    
    func saveImage(index: Int, item: SPItem) {
        let image = self.images[index]
        image.itemId = item.id
        // Save each Image
        image.addToServer(completion: { (err) in
            if err != nil {
                print("Can not save image: \(index)")
            } else {
                if (item.backgroundUrl == nil) || (item.backgroundUrl == "") {
                    item.backgroundUrl = image.destination
                }
            }
            // Update notification text UI
            DispatchQueue.main.async {
                let percentage = Int(Double(index + 1) / Double(self.images.count) * 100)
                self.savingLabel.text = "Saving: \(percentage)%"
            }
            // Update images field in Item
            if (index == self.images.count - 1) {
                var imageIds = [String]()
                for image in self.images {
                    if image.id != nil {
                        imageIds.append(image.id!)
                    }
                }
                item.images = imageIds
                item.updateToServer(completion: { (err) in
                    if let error = err {
                        print("Can not update imageIds to Item: \(error.localizedDescription)")
                        return
                    }
                })
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.savingIndicatorView.stopAnimating()
                    self.handleClose(nil)
                }
            }
            
            if index < self.images.count - 1 {
                self.saveImage(index: index + 1, item: item)
            }
        })
    }
}
