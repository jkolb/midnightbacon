//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinkCell : UITableViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
    @IBOutlet var thumbnailAspectRatio: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var linkTitle: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
            titleLabel?.invalidateIntrinsicContentSize()
        }
    }
    
    var thumbnailImage: UIImage? {
        get {
            return thumbnailImageView?.image
        }
        set {
            thumbnailImageView?.image = newValue
            thumbnailImageView?.invalidateIntrinsicContentSize()
            setNeedsUpdateConstraints()
        }
    }

    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            println("Set frame: \(newValue)")
            super.frame = newValue
        }
    }
    
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            println("Set bounds: \(newValue)")
            super.bounds = newValue
        }
    }

    override func updateConstraints() {
        thumbnailAspectRatio?.constant = 1.0
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        println("LinkCell layoutSubviews: \(titleLabel!.frame)")
        super.layoutSubviews()
        println("LinkCell layoutSubviews: \(titleLabel!.frame)")
    }
}


class TestLabel : UILabel {
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            println("Label Set frame: \(newValue)")
            super.frame = newValue
        }
    }
    
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            println("Label Set bounds: \(newValue)")
            super.bounds = newValue
//            preferredMaxLayoutWidth = CGRectGetWidth(newValue)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        println("Label layoutSubviews: \(frame)")
        super.layoutSubviews()
        println("Label layoutSubviews: \(frame)")
    }
}
