//
//  LinksViewController.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None
        extendedLayoutIncludesOpaqueBars = true
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerNib(UINib(nibName: "LinkCell", bundle: nil), forCellWithReuseIdentifier: "LinkCell")
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        view.addSubview(collectionView)
        
    }
    
    override func updateViewConstraints() {
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0.0))
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LinkCell", forIndexPath: indexPath) as LinkCell
        
        if indexPath.row == 0 {
            cell.titleLabel?.text = "TIL there is a $100 coin that is legal U.S. tender. They weigh1 ounce and are 99.95% platinum. This is the highest face value ever to appear on a U.S. coin."
        } else {
            cell.titleLabel?.text = "TIL there is a $100 coin that is legal U.S."
        }
        let thumbnailData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("placeholderThumbnail", ofType: "jpg")!)
        let thumbnail = UIImage(data: thumbnailData!, scale: 2.0)
        cell.image = thumbnail
        cell.layer.borderColor = UIColor.redColor().CGColor
        cell.layer.borderWidth = 1.0
        cell.titleLabel?.layer.borderColor = UIColor.blueColor().CGColor
        cell.titleLabel?.layer.borderWidth = 1.0
        cell.thumbnailImageView?.layer.borderColor = UIColor.greenColor().CGColor
        cell.thumbnailImageView?.layer.borderWidth = 1.0
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let nib = UINib(nibName: "LinkCell", bundle: nil)
        let cell = nib?.instantiateWithOwner(nil, options: nil)[0] as LinkCell
        
        if indexPath.row == 0 {
            cell.titleLabel?.text = "TIL there is a $100 coin that is legal U.S. tender. They weigh1 ounce and are 99.95% platinum. This is the highest face value ever to appear on a U.S. coin."
        } else {
            cell.titleLabel?.text = "TIL there is a $100 coin that is legal U.S."
        }
        let thumbnailData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("placeholderThumbnail", ofType: "jpg")!)
        let thumbnail = UIImage(data: thumbnailData!, scale: 2.0)
        cell.image = thumbnail
        cell.layoutIfNeeded()
        let cellSize = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return CGSize(width: CGRectGetWidth(collectionView.bounds), height: cellSize.height)
    }
}
