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
        
        upvoteButton.frame = layout.upvoteFrame
        downvoteButton.frame = layout.downvoteFrame
        titleLabel.frame = layout.titleFrame
        commentsButton.frame = layout.commentsFrame
        authorLabel.frame = layout.authorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let maxBottom = max(layout.authorFrame.baseline(font: authorLabel.font), layout.downvoteFrame.bottom)
        return CGSize(width: size.width, height: maxBottom + layoutMargins.bottom)
    }

    struct CellLayout {
        let titleFrame: CGRect
        let upvoteFrame: CGRect
        let downvoteFrame: CGRect
        let commentsFrame: CGRect
        let authorFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let upvoteFrame = upvoteButton.layout(
            Trailing(equalTo: bounds.trailing(layoutMargins)),
            Top(equalTo: bounds.top(layoutMargins)),
            Width(equalTo: measurements.voteSize.width),
            Height(equalTo: measurements.voteSize.height)
        )
        
        let titleFrame = titleLabel.layout(
            Leading(equalTo: bounds.leading(layoutMargins)),
            Trailing(equalTo: upvoteFrame.leading, constant: -measurements.horizontalSpacing),
            Capline(equalTo: upvoteFrame.top)
        )

        let downvoteFrame = downvoteButton.layout(
            Leading(equalTo: upvoteFrame.leading),
            Top(equalTo: upvoteFrame.bottom, constant: 4.0),
            Width(equalTo: measurements.voteSize.width),
            Height(equalTo: measurements.voteSize.height)
        )
        
        let commentsFrame = commentsButton.layout(
            Leading(equalTo: titleFrame.leading),
            Top(equalTo: titleFrame.baseline(font: titleLabel.font))
        )
        
        var authorFrame = authorLabel.layout(
            Leading(equalTo: bounds.leading(layoutMargins)),
            Trailing(equalTo: titleFrame.trailing),
            Capline(equalTo: commentsFrame.bottom)
        )
        
        if authorFrame.baseline(font: authorLabel.font) < downvoteFrame.bottom {
            authorFrame = authorLabel.layout(
                Leading(equalTo: bounds.leading(layoutMargins)),
                Trailing(equalTo: titleFrame.trailing),
                Baseline(equalTo: downvoteFrame.bottom)
            )
        } else if authorFrame.capline(font: authorLabel.font) > downvoteFrame.bottom + measurements.verticalSpacing {
            authorFrame = authorLabel.layout(
                Leading(equalTo: bounds.leading(layoutMargins)),
                Trailing(equalTo: bounds.trailing(layoutMargins)),
                Capline(equalTo: commentsFrame.bottom)
            )
        }
        
        return CellLayout(
            titleFrame: titleFrame,
            upvoteFrame: upvoteFrame,
            downvoteFrame: downvoteFrame,
            commentsFrame: commentsFrame,
            authorFrame: authorFrame
        )
    }
}
