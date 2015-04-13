//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinkCell : ListViewCell {
    struct Measurements {
        let horizontalSpacing = CGFloat(8.0)
        let verticalSpacing = CGFloat(8.0)
        let thumbnailSize = CGSize(width: 70.0, height: 70.0)
    }
    
    var measurements = Measurements()
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    let ageLabel = UILabel()
    let separatorView = UIView()
    var insets = UIEdgeInsetsZero
    var separatorHeight: CGFloat = 0.0
    var styled = false
    
    required init(frame: CGRect, reuseIdentifier: String) {
        super.init(frame: frame, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(ageLabel)
        contentView.addSubview(separatorView)
        
//        titleLabel.layer.borderColor = UIColor.redColor().CGColor
//        titleLabel.layer.borderWidth = 1.0
//        
//        authorLabel.layer.borderColor = UIColor.greenColor().CGColor
//        authorLabel.layer.borderWidth = 1.0
//        
//        ageLabel.layer.borderColor = UIColor.blueColor().CGColor
//        ageLabel.layer.borderWidth = 1.0
    }
}
