//
//  TextOnlyLinkCell.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import DrapierLayout

class TextOnlyLinkCell : LinkCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(contentView.bounds)
        
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
            Bottom(equalTo: authorFrame.baseline(font: authorLabel.font) + insets.bottom),
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
