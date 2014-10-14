//
//  MainMenuViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    struct Style {
        let backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        let foregroundColor = UIColor(white: 0.04, alpha: 1.0)
        let separatorColor = UIColor(white: 0.04, alpha: 0.2)
        //        let backgroundColor = UIColor(white: 0.04, alpha: 1.0)
        //        let foregroundColor = UIColor(white: 0.96, alpha: 1.0)
        //        let separatorColor = UIColor(white: 0.96, alpha: 0.2)
        //        let upvoteColor = UIColor(red: 0.98, green: 0.28, blue: 0.12, alpha: 1.0)
        //        let downvoteColor = UIColor(red: 0.12, green: 0.28, blue: 0.98, alpha: 1.0)
        let upvoteColor = UIColor(red: 255.0/255.0, green: 139.0/255.0, blue: 96.0/255.0, alpha: 1.0) // ff8b60
        let downvoteColor = UIColor(red: 148.0/255.0, green: 148.0/255.0, blue: 255.0/255.0, alpha: 1.0) // 9494ff
    }
    
    var tableView: UITableView!
    let style = Style()
    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .Grouped)
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SubredditCell")
        tableView.backgroundColor = style.backgroundColor
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = style.separatorColor
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = selectedIndexPath {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Subreddits"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "All"
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        let linksViewController = LinksViewController()
        linksViewController.title = "All"
        navigationController?.pushViewController(linksViewController, animated: true)
    }
}
