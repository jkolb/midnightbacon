//
//  ThumbnailLinkCell.swift
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

class ThumbnailLinkCell : LinkCell {
    let thumbnailImageView = UIImageView()

    var isThumbnailSet: Bool {
        return thumbnailImage != nil
    }
    
    var thumbnailImage: UIImage? {
        get {
            return thumbnailImageView.image
        }
        set {
            thumbnailImageView.image = newValue
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
    }
    
    override func configure() {
        super.configure()
        contentView.addSubview(thumbnailImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(contentView.bounds)
        
        thumbnailImageView.frame = layout.thumbnailFrame
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
        let thumbnailFrame: CGRect
        let titleFrame: CGRect
        let ageFrame: CGRect
        let authorFrame: CGRect
        let separatorFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        var thumbnailFrame = thumbnailImageView.layout(
            Trailing(equalTo: bounds.trailing(insets)),
            Top(equalTo: bounds.top(insets)),
            Width(equalTo: measurements.thumbnailSize.width),
            Height(equalTo: measurements.thumbnailSize.height)
        )

        let titleFrame = titleLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: thumbnailFrame.leading, constant: -measurements.horizontalSpacing),
            Capline(equalTo: bounds.top(insets))
        )
        
        if titleFrame.height > thumbnailFrame.height {
            thumbnailFrame = thumbnailImageView.layout(
                Trailing(equalTo: bounds.trailing(insets)),
                CenterY(equalTo: titleFrame.centerY),
                Width(equalTo: measurements.thumbnailSize.width),
                Height(equalTo: measurements.thumbnailSize.height)
            )
        }

        let ageFrame = ageLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Capline(equalTo: titleFrame.baseline(font: titleLabel.font), constant: measurements.verticalSpacing)
        )
        
        var authorFrame = authorLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: ageFrame.baseline(font: ageLabel.font), constant: measurements.verticalSpacing)
        )

        if authorFrame.top < thumbnailFrame.bottom + measurements.verticalSpacing {
            authorFrame = authorLabel.layout(
                Leading(equalTo: bounds.leading(insets)),
                Trailing(equalTo: bounds.trailing(insets)),
                Capline(equalTo: thumbnailFrame.bottom, constant: measurements.verticalSpacing)
            )
        }
        
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: authorFrame.baseline(font: authorLabel.font) + insets.bottom),
            Height(equalTo: separatorHeight)
        )

        return CellLayout(
            thumbnailFrame: thumbnailFrame,
            titleFrame: titleFrame,
            ageFrame: ageFrame,
            authorFrame: authorFrame,
            separatorFrame: separatorFrame
        )
    }
}
