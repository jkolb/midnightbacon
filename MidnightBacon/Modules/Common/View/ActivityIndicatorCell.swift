//
//  ActivityIndicatorCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class ActivityIndicatorCell : UITableViewCell {
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        let style = MainStyle()
        backgroundColor = style.lightColor
        activityIndicatorView.color = style.darkColor
        contentView.addSubview(activityIndicatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityIndicatorView.frame = activityIndicatorView.layout(
            CenterX(equalTo: bounds.centerX(layoutMargins)),
            CenterY(equalTo: bounds.centerY(layoutMargins))
        )
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let activitySize = activityIndicatorView.sizeThatFits(CGSize.fixedWidth(size.width))
        
        return CGSize(width: size.width, height: layoutMargins.top + activitySize.height + layoutMargins.bottom)
    }
}
