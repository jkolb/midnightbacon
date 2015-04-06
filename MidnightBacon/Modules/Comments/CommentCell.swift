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
    let bodyLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        contentView.addSubview(bodyLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct CellLayout {
        let bodyFrame: CGRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(contentView.bounds)
        bodyLabel.frame = layout.bodyFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        var size = layout.bodyFrame.size
        size.width += layoutMargins.right
        size.height += layoutMargins.bottom
        return size
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let bodyFrame = bodyLabel.layout(
            Leading(equalTo: bounds.leading(layoutMargins)),
            Trailing(equalTo: bounds.trailing(layoutMargins)),
            Capline(equalTo: bounds.top(layoutMargins))
        )
        return CellLayout(bodyFrame: bodyFrame)
    }
}
