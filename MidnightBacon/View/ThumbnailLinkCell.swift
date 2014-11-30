//
//  ThumbnailLinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/27/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class ThumbnailLinkCell : LinkCell {
    let thumbnailImageView = UIImageView()
    
    override func configure() {
        super.configure()
        contentView.addSubview(thumbnailImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(bounds)
        
        thumbnailImageView.frame = layout.thumbnailFrame
        upvoteButton.frame = layout.upvoteFrame
        downvoteButton.frame = layout.downvoteFrame
        titleLabel.frame = layout.titleFrame
        commentsButton.frame = layout.commentsFrame
        authorLabel.frame = layout.authorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        return CGSize(width: size.width, height: layout.authorFrame.baseline(font: authorLabel.font) + layoutMargins.bottom)
    }
    
    struct CellLayout {
        let thumbnailFrame: CGRect
        let titleFrame: CGRect
        let upvoteFrame: CGRect
        let downvoteFrame: CGRect
        let commentsFrame: CGRect
        let authorFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let upvoteFrame = upvoteButton.layout(
            Trailing(equalTo: bounds.trailing(layoutMargins)),
            Top(equalTo: bounds.top(layoutMargins))
        )
        
        var thumbnailFrame = thumbnailImageView.layout(
            Leading(equalTo: bounds.leading(layoutMargins)),
            Top(equalTo: upvoteFrame.top),
            Width(equalTo: measurements.thumbnailSize.width),
            Height(equalTo: measurements.thumbnailSize.height)
        )

        let titleFrame = titleLabel.layout(
            Leading(equalTo: thumbnailFrame.trailing, constant: measurements.horizontalSpacing),
            Trailing(equalTo: upvoteFrame.leading, constant: -measurements.horizontalSpacing),
            Capline(equalTo: bounds.top(layoutMargins))
        )

        var commentsFrame: CGRect!
        
        if titleFrame.height > thumbnailFrame.height {
            thumbnailFrame = thumbnailImageView.layout(
                Leading(equalTo: bounds.leading(layoutMargins)),
                CenterY(equalTo: titleFrame.centerY),
                Width(equalTo: measurements.thumbnailSize.width),
                Height(equalTo: measurements.thumbnailSize.height)
            )
            
            commentsFrame = commentsButton.layout(
                Leading(equalTo: thumbnailFrame.trailing, constant: measurements.horizontalSpacing),
                Top(equalTo: titleFrame.baseline(font: commentsButton.titleLabel!.font))
            )
        } else {
            commentsFrame = commentsButton.layout(
                Leading(equalTo: thumbnailFrame.trailing, constant: measurements.horizontalSpacing),
                Top(equalTo: titleFrame.baseline(font: commentsButton.titleLabel!.font))
            )
        }
        
        var authorFrame: CGRect!

        if commentsFrame.bottom > thumbnailFrame.bottom {
            authorFrame = authorLabel.layout(
                Leading(equalTo: bounds.leading(layoutMargins)),
                Trailing(equalTo: bounds.trailing(layoutMargins)),
                Capline(equalTo: commentsFrame.bottom)
            )
        } else {
            authorFrame = authorLabel.layout(
                Leading(equalTo: bounds.leading(layoutMargins)),
                Trailing(equalTo: bounds.trailing(layoutMargins)),
                Capline(equalTo: thumbnailFrame.bottom, constant: measurements.verticalSpacing)
            )
        }
        
        let downvoteFrame = downvoteButton.layout(
            Leading(equalTo: upvoteFrame.leading),
            Top(equalTo: upvoteFrame.bottom, constant: 4.0)
        )
        
        return CellLayout(
            thumbnailFrame: thumbnailFrame,
            titleFrame: titleFrame,
            upvoteFrame: upvoteFrame,
            downvoteFrame: downvoteFrame,
            commentsFrame: commentsFrame,
            authorFrame: authorFrame
        )
    }
}
