//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinkCell : UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
    @IBOutlet var thumbnailAspectRatio: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = CGRectGetWidth(titleLabel!.frame)
    }
    
    var title: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
            titleLabel?.invalidateIntrinsicContentSize()
        }
    }
    
    var image: UIImage? {
        get {
            return thumbnailImageView?.image
        }
        set {
            thumbnailImageView?.image = newValue
            thumbnailImageView?.invalidateIntrinsicContentSize()
            setNeedsUpdateConstraints()
        }
    }
    
    override func updateConstraints() {
        thumbnailAspectRatio?.constant = 1.0
        super.updateConstraints()
    }
}
