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
    var insets = UIEdgeInsetsZero

    required init(frame: CGRect, reuseIdentifier: String) {
        super.init(frame: frame, reuseIdentifier: reuseIdentifier)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.opaque = true
        
        addSubview(bodyLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct CellLayout {
        let bodyFrame: CGRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = generateLayout(bounds)
        bodyLabel.frame = layout.bodyFrame
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
        return CellLayout(bodyFrame: bodyFrame)
    }
}
