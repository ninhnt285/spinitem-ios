//
//  HomeViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/8/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    var items = [SPItem]()
    
    var logoutButton: UIBarButtonItem!
    lazy var rc: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        rc.tintColor = UIColor.gray
        
        return rc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        self.refreshControl = rc
        // Add dummy item for Simulator
//        let saveBtn = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSave(_:)))
//        self.navigationItem.rightBarButtonItem = saveBtn
    }
    
//    @objc func handleSave(_ sender: Any?) {
//        let image1 = SPImage()
//        image1.fileData = UIImagePNGRepresentation(UIImage(named: "Logo")!)
//        let image2 = SPImage()
//        image2.fileData = UIImagePNGRepresentation(UIImage(named: "Square-Logo")!)
//        
//        let previewViewController = PreviewViewController(previewImages: [image1, image2])
//        previewViewController.canSaveImage = true
//        self.present(previewViewController, animated: true, completion: nil)
//    }
    
    func configureSubviews() {
        self.view.backgroundColor = ColorSettings.backgroundColor
        self.title = "All Items"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ItemCell.self, forCellReuseIdentifier: "itemCell")
        self.tableView.rowHeight = 64
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData {
            self.tableView.reloadData()
        }
    }
    
    // Data
    func reloadData(completionHandler: @escaping () -> ()) {
        SPItem.getAllItems { (items, err) in
            // Check all errors
            if err != nil {
                self.items = []
            } else {
                self.items = items!
            }
            DispatchQueue.main.async(execute: {
                completionHandler()
            })
        }
    }
    
    // Handler
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        reloadData {
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    @objc func handleLogout(_ sender:Any) {
        try! SPAuth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
    
    // UITableViewDelegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemCell
        cell.textLabel?.text = item.title
        if let backgroundUrl = item.backgroundUrl {
            cell.bgImageView?.loadImageFromCacheUrl(url: backgroundUrl.replacingOccurrences(of: "%s", with: "_50x50_square"))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        let itemId = item.id
        
        SPImage.getAllByItemId(itemId: itemId!) { (images, err) in
            // Check for any errors
            if let error = err {
                print(error.localizedDescription)
                return
            }
            // Prepare images
            let newImages = images?.sorted(by: { (image1, image2) -> Bool in
                image1.index! < image2.index!
            })
            DispatchQueue.main.async(execute: {
                let previewViewController = PreviewViewController(previewImages: newImages!)
                self.present(previewViewController, animated: true, completion: nil)
            })
        }
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = items[indexPath.row]
        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit Name") { (action, indexPath) in
            let alertController = UIAlertController(title: "Edit name", message: "Enter new Item Name", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (action) in
                if let newTitle = alertController.textFields?.first?.text {
                    // Reload data in local first
                    item.title = newTitle
                    self.tableView.reloadData()
                    // Then Reload data from server
                    item.updateToServer(completion: { (err) in
                        self.reloadData {
                            self.tableView.reloadData()
                        }
                    })
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            alertController.addTextField(configurationHandler: { (textField) in
                textField.text = item.title
            })
            self.present(alertController, animated: true, completion: nil)
        }
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action, indexPath) in
            // Delete in local first
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            // Update from Server
            item.deleteToServer(completion: { (err) in
                self.reloadData {
                    self.tableView.reloadData()
                }
            })
        }
        return [delete, edit]
    }
}

class ItemCell: UITableViewCell {
    var bgImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        bgImageView = UIImageView()
        addSubview(bgImageView)
    }
    
    func configureSubviews() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewSize = self.frame.size
        bgImageView.frame = CGRect(x: 8, y: 8, width: viewSize.height - 16, height: viewSize.height - 16)
        textLabel?.frame = CGRect(x: viewSize.height, y: 8, width: viewSize.width - viewSize.height, height: viewSize.height - 16)
    }
}
