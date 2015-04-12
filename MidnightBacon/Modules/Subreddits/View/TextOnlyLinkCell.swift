//
//  TextOnlyLinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class TextOnlyLinkCell : LinkCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(bounds)
        
        titleLabel.frame = layout.titleFrame
        ageLabel.frame = layout.ageFrame
        authorLabel.frame = layout.authorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let maxBottom = layout.authorFrame.baseline(font: authorLabel.font)
        return CGSize(width: size.width, height: maxBottom + layoutMargins.bottom)
    }

    struct CellLayout {
        let titleFrame: CGRect
        let ageFrame: CGRect
        let authorFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let titleFrame = titleLabel.layout(
            Leading(equalTo: bounds.leading(layoutMargins)),
            Trailing(equalTo: bounds.trailing(layoutMargins)),
            Capline(equalTo: bounds.top(layoutMargins))
        )
        
        let ageFrame = ageLabel.layout(
            Leading(equalTo: titleFrame.leading),
            Capline(equalTo: titleFrame.baseline(font: titleLabel.font), constant: measurements.verticalSpacing)
        )
        
        var authorFrame = authorLabel.layout(
            Leading(equalTo: bounds.leading(layoutMargins)),
            Trailing(equalTo: titleFrame.trailing),
            Capline(equalTo: ageFrame.baseline(font: ageLabel.font), constant: measurements.verticalSpacing)
        )
        
        return CellLayout(
            titleFrame: titleFrame,
            ageFrame: ageFrame,
            authorFrame: authorFrame
        )
    }
}
