//
//  CommentCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class CommentCell : ListViewCell {
    let bodyLabel = UILabel()
    let separatorView = UIView()
    var insets = UIEdgeInsetsZero
    var separatorHeight: CGFloat = 0.0
    
    required init(frame: CGRect, reuseIdentifier: String) {
        super.init(frame: frame, reuseIdentifier: reuseIdentifier)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.opaque = true
        
        contentView.addSubview(bodyLabel)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct CellLayout {
        let bodyFrame: CGRect
        let separatorFrame: CGRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = generateLayout(contentView.bounds)
        bodyLabel.frame = layout.bodyFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let maxBottom = layout.bodyFrame.bottom
        return CGSize(width: size.width, height: maxBottom + insets.bottom)
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let bodyFrame = bodyLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: bounds.top(insets))
        )
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: bodyFrame.bottom + insets.bottom - separatorHeight),
            Height(equalTo: separatorHeight)
        )
        return CellLayout(
            bodyFrame: bodyFrame,
            separatorFrame: separatorFrame
        )
    }
}
