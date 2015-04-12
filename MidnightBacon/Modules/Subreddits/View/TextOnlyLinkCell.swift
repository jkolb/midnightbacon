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
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let maxBottom = layout.authorFrame.baseline(font: authorLabel.font)
        return CGSize(width: size.width, height: maxBottom + insets.bottom)
    }

    struct CellLayout {
        let titleFrame: CGRect
        let ageFrame: CGRect
        let authorFrame: CGRect
        let separatorFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let titleFrame = titleLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: bounds.top(insets))
        )
        
        let ageFrame = ageLabel.layout(
            Leading(equalTo: titleFrame.leading),
            Capline(equalTo: titleFrame.baseline(font: titleLabel.font), constant: measurements.verticalSpacing)
        )
        
        let authorFrame = authorLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: titleFrame.trailing),
            Capline(equalTo: ageFrame.baseline(font: ageLabel.font), constant: measurements.verticalSpacing)
        )
        
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: authorFrame.baseline(font: authorLabel.font) + insets.bottom - separatorHeight),
            Height(equalTo: separatorHeight)
        )

        return CellLayout(
            titleFrame: titleFrame,
            ageFrame: ageFrame,
            authorFrame: authorFrame,
            separatorFrame: separatorFrame
        )
    }
}
