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
    let authorLabel = UILabel()
    let bodyLabel = UILabel()
    let indentionView = UIView()
    let separatorView = UIView()
    var insets = UIEdgeInsetsZero
    var separatorHeight: CGFloat = 0.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.opaque = true
        
        contentView.addSubview(bodyLabel)
        contentView.addSubview(authorLabel)
//        contentView.addSubview(indentionView)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct CellLayout {
        let authorFrame: CGRect
        let bodyFrame: CGRect
        let indentionFrame: CGRect
        let separatorFrame: CGRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = generateLayout(contentView.bounds)
        authorLabel.frame = layout.authorFrame
        bodyLabel.frame = layout.bodyFrame
        indentionView.frame = layout.indentionFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let maxBottom = layout.bodyFrame.bottom
        return CGSize(width: size.width, height: maxBottom + insets.bottom)
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let indent = CGFloat(indentationLevel) * CGFloat(4.0)
        let authorFrame = authorLabel.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: bounds.top(insets))
        )
        let bodyFrame = bodyLabel.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: authorFrame.baseline(font: authorLabel.font), constant: CGFloat(8.0))
        )
        let indentionFrame = indentionView.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent - CGFloat(8.0)),
            Top(equalTo: bounds.top),
            Width(equalTo: separatorHeight),
            Height(equalTo: bounds.height)
        )
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: bodyFrame.bottom + insets.bottom),
            Height(equalTo: separatorHeight)
        )
        return CellLayout(
            authorFrame: authorFrame,
            bodyFrame: bodyFrame,
            indentionFrame: indentionFrame,
            separatorFrame: separatorFrame
        )
    }
}
