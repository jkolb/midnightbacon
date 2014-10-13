//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinkCellMeasurements {
    let thumbnailSize = CGSize(width: 44.0, height: 44.0)
    let voteSize = CGSize(width: 24.0, height: 24.0)
    let voteGap = CGFloat(2.0)
    let horizontalSpacing = CGFloat(8.0)
    let verticalSpacing = CGFloat(8.0)
    let buttonHeight = CGFloat(26.0)
}

class LinkCell : UITableViewCell {
    var measurements = LinkCellMeasurements()
    let titleLabel = UILabel()
    let thumbnailImageView = UIImageView()
    let upvoteButton = UIButton()
    let downvoteButton = UIButton()
    let subredditButton = UIButton()
    let domainButton = UIButton()
    let authorButton = UIButton()
    let commentsButton = UIButton()
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(bounds.size)
        
        thumbnailImageView.frame = layout.thumbnailFrame
        upvoteButton.frame = layout.upvoteFrame
        downvoteButton.frame = layout.downvoteFrame
        titleLabel.frame = layout.titleFrame
        commentsButton.frame = layout.commentsFrame
//
//        if height(titleLabel) > height(thumbnailImageView) {
//            
//        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size)
        return CGSize(width: size.width, height: bottom(layout.commentsFrame) + layoutMargins.bottom)
    }

    struct Layout {
        let thumbnailFrame: CGRect
        let titleFrame: CGRect
        let upvoteFrame: CGRect
        let downvoteFrame: CGRect
        let commentsFrame: CGRect
    }
    
    func generateLayout(size: CGSize) -> Layout {
        let contentBounds = CGRect(size: size).inset(layoutMargins)
        let font = titleLabel.font
        let titleCaplineOffset = round(font.ascender - font.capHeight)
        
        let thumbnailFrame = thumbnailImageView.layout(
            .Left(equalTo: left(contentBounds), multiplier: 1.0, constant: 0.0),
            .Top(equalTo: top(contentBounds), multiplier: 1.0, constant: 0.0),
            .Size(measurements.thumbnailSize)
        )
        let upvoteFrame = upvoteButton.layout(
            .Right(equalTo: right(contentBounds), multiplier: 1.0, constant: 0.0),
            .Top(equalTo: top(contentBounds), multiplier: 1.0, constant: 0.0),
            .Size(measurements.voteSize)
        )
        let titleFrame = titleLabel.layout(
            left: right(thumbnailFrame) + measurements.horizontalSpacing,
            right: left(upvoteFrame) - measurements.horizontalSpacing,
            .Top(equalTo: top(contentBounds), multiplier: 1.0, constant: -titleCaplineOffset)
        )
        let downvoteFrame = downvoteButton.layout(
            .Left(equalTo: left(upvoteFrame), multiplier: 1.0, constant: 0.0),
            .Top(equalTo: bottom(upvoteFrame), multiplier: 1.0, constant: measurements.voteGap),
            .Size(measurements.voteSize)
        )
        let commentsFrame = commentsButton.layout(
            .Right(equalTo: right(contentBounds), multiplier: 1.0, constant: 0.0),
            .Top(equalTo: bottom(downvoteFrame), multiplier: 1.0, constant: measurements.verticalSpacing),
            .FitSize(fixedHeight(measurements.buttonHeight))
        )
        
        return Layout(
            thumbnailFrame: thumbnailFrame,
            titleFrame: titleFrame,
            upvoteFrame: upvoteFrame,
            downvoteFrame: downvoteFrame,
            commentsFrame: commentsFrame
        )
    }
}
