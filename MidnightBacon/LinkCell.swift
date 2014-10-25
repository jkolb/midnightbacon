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
        
        authorButton.hidden = authorButton.frame.width < 70.0
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        return CGSize(width: size.width, height: layout.commentsFrame.bottom(layoutMargins))
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
            Leading(equalTo: contentBounds.leading),
            Top(equalTo: contentBounds.top),
            Width(equalTo: measurements.thumbnailSize.width),
            Height(equalTo: measurements.thumbnailSize.height)
        )
        let upvoteFrame = upvoteButton.layout(
            Trailing(equalTo: contentBounds.trailing),
            Top(equalTo: contentBounds.top),
            Width(equalTo: measurements.voteSize.width),
            Height(equalTo: measurements.voteSize.height)
        )
        let titleFrame = titleLabel.layout(
            Leading(equalTo: thumbnailFrame.trailing, constant: measurements.horizontalSpacing),
            Trailing(equalTo: upvoteFrame.leading, constant: -measurements.horizontalSpacing),
            Capline(equalTo: contentBounds.top)
        )
        
        if titleFrame.height > thumbnailFrame.height {
            thumbnailFrame = thumbnailImageView.layout(
                Leading(equalTo: contentBounds.leading),
                CenterY(equalTo: titleFrame.centerY),
                Width(equalTo: measurements.thumbnailSize.width),
                Height(equalTo: measurements.thumbnailSize.height)
            )
        }
        
        let downvoteFrame = downvoteButton.layout(
            Leading(equalTo: upvoteFrame.leading),
            Top(equalTo: upvoteFrame.bottom, constant: measurements.voteGap),
            Width(equalTo: measurements.voteSize.width),
            Height(equalTo: measurements.voteSize.height)
        )
        
        var commentsFrame = commentsButton.layout(
            Trailing(equalTo: titleFrame.trailing),
            Top(equalTo: titleFrame.baseline(commentsButton.titleLabel!.font.descender), constant: measurements.verticalSpacing),
            Height(equalTo: measurements.buttonHeight)
        )
        
        if commentsFrame.bottom < downvoteFrame.bottom {
            commentsFrame = commentsButton.layout(
                Trailing(equalTo: titleFrame.trailing),
                Bottom(equalTo: downvoteFrame.bottom),
                Height(equalTo: measurements.buttonHeight)
            )
        }
        
        var authorFrame = authorButton.layout(
            Leading(equalTo: titleFrame.leading),
            Top(equalTo: commentsFrame.top),
            Height(equalTo: measurements.buttonHeight)
        )
        
        if authorFrame.right > commentsFrame.left - measurements.horizontalSpacing {
            authorFrame = authorButton.layout(
                Leading(equalTo: titleFrame.leading),
                Trailing(equalTo: commentsFrame.leading, constant: -measurements.horizontalSpacing),
                Top(equalTo: commentsFrame.top),
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
