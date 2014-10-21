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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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

    struct CellLayout {
        let thumbnailFrame: CGRect
        let titleFrame: CGRect
        let upvoteFrame: CGRect
        let downvoteFrame: CGRect
        let commentsFrame: CGRect
        let authorFrame: CGRect
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let contentBounds = bounds.inset(layoutMargins)
        
        var thumbnailFrame = thumbnailImageView.layout(
            Left(equalTo: left(contentBounds)),
            Top(equalTo: top(contentBounds)),
            Width(equalTo: measurements.thumbnailSize.width),
            Height(equalTo: measurements.thumbnailSize.height)
        )
        let upvoteFrame = upvoteButton.layout(
            Right(equalTo: right(contentBounds)),
            Top(equalTo: top(contentBounds)),
            Width(equalTo: measurements.voteSize.width),
            Height(equalTo: measurements.voteSize.height)
        )
        let titleFrame = titleLabel.layout(
            Left(equalTo: right(thumbnailFrame), constant: measurements.horizontalSpacing),
            Right(equalTo: left(upvoteFrame), constant: -measurements.horizontalSpacing),
            Capline(equalTo:top(contentBounds))
        )
        
        if height(titleFrame) > height(thumbnailFrame) {
            thumbnailFrame = thumbnailImageView.layout(
                Left(equalTo: left(contentBounds)),
                CenterY(equalTo: centerY(titleFrame)),
                Width(equalTo: measurements.thumbnailSize.width),
                Height(equalTo: measurements.thumbnailSize.height)
            )        }
        
        let downvoteFrame = downvoteButton.layout(
            Left(equalTo: left(upvoteFrame)),
            Top(equalTo: bottom(upvoteFrame), constant: measurements.voteGap),
            Width(equalTo: measurements.voteSize.width),
            Height(equalTo: measurements.voteSize.height)
        )
        
        var commentsFrame = commentsButton.layout(
            Right(equalTo: right(titleFrame)),
            Top(equalTo: bottom(titleFrame), constant: measurements.voteGap),
            Height(equalTo: measurements.buttonHeight)
        )
        
        if bottom(commentsFrame) < bottom(downvoteFrame) {
            commentsFrame = commentsButton.layout(
                Right(equalTo: right(titleFrame)),
                Bottom(equalTo: bottom(downvoteFrame)),
                Height(equalTo: measurements.buttonHeight)
            )
        }
        
        var authorFrame = authorButton.layout(
            Left(equalTo: left(titleFrame)),
            Top(equalTo: top(commentsFrame)),
            Height(equalTo: measurements.buttonHeight)
        )
        
        if right(authorFrame) > left(commentsFrame) - measurements.horizontalSpacing {
            authorFrame = authorButton.layout(
                Left(equalTo: left(titleFrame)),
                Right(equalTo: left(commentsFrame), constant: -measurements.horizontalSpacing),
                Top(equalTo:top(commentsFrame)),
                Height(equalTo: measurements.buttonHeight)
            )
        }
        
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
