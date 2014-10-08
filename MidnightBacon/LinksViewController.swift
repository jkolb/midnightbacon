//
//  LinksViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None
        extendedLayoutIncludesOpaqueBars = true

        tableView = UITableView(frame: view.bounds, style: .Plain)
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "LinkCell", bundle: nil)!, forCellReuseIdentifier: "LinkCell")
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        view.addSubview(tableView)
        
    }
    
    override func updateViewConstraints() {
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0.0))
        super.updateViewConstraints()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("Dequeue cell")
        let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as LinkCell
        println("Dequeued cell")
        
        if indexPath.row == 0 {
            cell.linkTitle = "TIL there is a $100 coin that is legal U.S. tender. They weigh1 ounce and are 99.95% platinum. This is the highest face value ever to appear on a U.S. coin."
        } else {
            cell.linkTitle = "TIL there is a $100 coin that is legal U.S."
        }
        let thumbnailData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("placeholderThumbnail", ofType: "jpg")!)
        let thumbnail = UIImage(data: thumbnailData!, scale: 2.0)
        cell.thumbnailImage = thumbnail
        cell.layer.borderColor = UIColor.redColor().CGColor
        cell.layer.borderWidth = 1.0
        cell.titleLabel?.layer.borderColor = UIColor.blueColor().CGColor
        cell.titleLabel?.layer.borderWidth = 1.0
        cell.thumbnailImageView?.layer.borderColor = UIColor.greenColor().CGColor
        cell.thumbnailImageView?.layer.borderWidth = 1.0
        return cell
    }
}
