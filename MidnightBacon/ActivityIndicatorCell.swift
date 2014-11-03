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
        let style = GlobalStyle()
        backgroundColor = style.lightColor
        activityIndicatorView.tintColor = style.darkColor
        contentView.addSubview(activityIndicatorView)
    }
    
    struct CellLayout {
        let activityFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let activityFrame = activityIndicatorView.layout(
            CenterX(equalTo: bounds.centerX(layoutMargins)),
            CenterY(equalTo: bounds.centerY(layoutMargins))
        )
        
        return CellLayout(
            activityFrame: activityFrame
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(bounds)
        
        activityIndicatorView.frame = layout.activityFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        
        return CGSize(width: size.width, height: layout.activityFrame.bottom + layoutMargins.bottom)
    }
}
