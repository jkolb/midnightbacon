//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinkCell : UITableViewCell {
    struct Measurements {
        let thumbnailSize = CGSize(width: 52.0, height: 52.0)
        let voteSize = CGSize(width: 24.0, height: 24.0)
        let voteGap = CGFloat(4.0)
        let horizontalSpacing = CGFloat(8.0)
        let verticalSpacing = CGFloat(8.0)
        let buttonHeight = CGFloat(24.0)
    }
    
    var measurements = Measurements()
    let titleLabel = UILabel()
    let thumbnailImageView = UIImageView()
    let upvoteButton = UIButton()
    let downvoteButton = UIButton()
    let authorButton = UIButton()
    let commentsButton = UIButton()
    var constraintsInstalled = false
    
    override init?(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(upvoteButton)
        contentView.addSubview(downvoteButton)
        contentView.addSubview(commentsButton)
        contentView.addSubview(authorButton)
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        thumbnailImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        upvoteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        downvoteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        commentsButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        authorButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(bounds)
        
        thumbnailImageView.frame = layout.thumbnailFrame
        upvoteButton.frame = layout.upvoteFrame
        downvoteButton.frame = layout.downvoteFrame
        titleLabel.frame = layout.titleFrame
        commentsButton.frame = layout.commentsFrame
        authorButton.frame = layout.authorFrame
        
        authorButton.hidden = width(authorButton.frame) < 70.0
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(CGRect(size: size))
        let maxBottom = max(bottom(layout.commentsFrame), bottom(layout.downvoteFrame))
        return CGSize(width: size.width, height: maxBottom + layoutMargins.bottom)
    }

    struct Layout {
        let thumbnailFrame: CGRect
        let titleFrame: CGRect
        let upvoteFrame: CGRect
        let downvoteFrame: CGRect
        let commentsFrame: CGRect
        let authorFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> Layout {
        let contentBounds = bounds.inset(layoutMargins)
        let font = titleLabel.font
        let titleCaplineOffset = round(font.ascender - font.capHeight)
        
        let thumbnailFrame = thumbnailImageView.layout(
            LeftAnchor(equalTo: left(contentBounds)),
            TopAnchor(equalTo: top(contentBounds)),
            WidthAnchor(equalTo: measurements.thumbnailSize.width),
            HeightAnchor(equalTo: measurements.thumbnailSize.height)
        )
        let upvoteFrame = upvoteButton.layout(
            RightAnchor(equalTo: right(contentBounds)),
            TopAnchor(equalTo: top(contentBounds)),
            WidthAnchor(equalTo: measurements.voteSize.width),
            HeightAnchor(equalTo: measurements.voteSize.height)
        )
        let titleFrame = titleLabel.layout(
            LeftAnchor(equalTo: right(thumbnailFrame), constant: measurements.horizontalSpacing),
            RightAnchor(equalTo: left(upvoteFrame), constant: -measurements.horizontalSpacing),
            TopAnchor(equalTo:top(contentBounds), constant: -titleCaplineOffset)
        )
        let downvoteFrame = downvoteButton.layout(
            LeftAnchor(equalTo: left(upvoteFrame)),
            TopAnchor(equalTo: bottom(upvoteFrame), constant: measurements.voteGap),
            WidthAnchor(equalTo: measurements.voteSize.width),
            HeightAnchor(equalTo: measurements.voteSize.height)
        )
        
        var commentsFrame = commentsButton.layout(
            RightAnchor(equalTo: right(titleFrame)),
            TopAnchor(equalTo: bottom(titleFrame), constant: measurements.voteGap),
            HeightAnchor(equalTo: measurements.buttonHeight)
        )
        
        if bottom(commentsFrame) < bottom(downvoteFrame) {
            commentsFrame = commentsButton.layout(
                RightAnchor(equalTo: right(titleFrame)),
                BottomAnchor(equalTo: bottom(downvoteFrame)),
                HeightAnchor(equalTo: measurements.buttonHeight)
            )
        }
        
        var authorFrame = authorButton.layout(
            LeftAnchor(equalTo: left(titleFrame)),
            TopAnchor(equalTo: top(commentsFrame)),
            HeightAnchor(equalTo: measurements.buttonHeight)
        )
        
        if right(authorFrame) > left(commentsFrame) - measurements.horizontalSpacing {
            authorFrame = authorButton.layout(
                LeftAnchor(equalTo: left(titleFrame)),
                RightAnchor(equalTo: left(commentsFrame), constant: -measurements.horizontalSpacing),
                TopAnchor(equalTo:top(commentsFrame)),
                HeightAnchor(equalTo: measurements.buttonHeight)
            )
        }
        
        return Layout(
            thumbnailFrame: thumbnailFrame,
            titleFrame: titleFrame,
            upvoteFrame: upvoteFrame,
            downvoteFrame: downvoteFrame,
            commentsFrame: commentsFrame,
            authorFrame: authorFrame
        )
    }
}
