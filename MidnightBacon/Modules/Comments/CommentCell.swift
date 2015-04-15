//
//  CommentCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/25/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class CommentCell : UITableViewCell {
    let depthLabel = UILabel()
    let bodyLabel = UILabel()
    let separatorView = UIView()
    var insets = UIEdgeInsetsZero
    var separatorHeight: CGFloat = 0.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.opaque = true
        
        contentView.addSubview(depthLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct CellLayout {
        let depthFrame: CGRect
        let bodyFrame: CGRect
        let separatorFrame: CGRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = generateLayout(contentView.bounds)
        depthLabel.frame = layout.depthFrame
        bodyLabel.frame = layout.bodyFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let maxBottom = layout.bodyFrame.bottom
        return CGSize(width: size.width, height: maxBottom + insets.bottom)
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let depthFrame = depthLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: bounds.top(insets))
        )
        let bodyFrame = bodyLabel.layout(
            Leading(equalTo: bounds.leading(insets), constant: CGFloat(8.0)),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: depthFrame.baseline(font: depthLabel.font), constant: CGFloat(8.0))
        )
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: bodyFrame.bottom + insets.bottom - separatorHeight),
            Height(equalTo: separatorHeight)
        )
        return CellLayout(
            depthFrame: depthFrame,
            bodyFrame: bodyFrame,
            separatorFrame: separatorFrame
        )
    }
}
