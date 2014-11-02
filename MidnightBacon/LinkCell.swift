//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class LinkCell : UITableViewCell {
    struct Measurements {
        let voteSize = CGSize(width: 24.0, height: 24.0)
        let horizontalSpacing = CGFloat(8.0)
        let verticalSpacing = CGFloat(8.0)
        let buttonHeight = CGFloat(24.0)
    }
    
    var measurements = Measurements()
    let titleLabel = UILabel()
    let upvoteButton = UIButton()
    let downvoteButton = UIButton()
    let authorLabel = UILabel()
    let commentsButton = UIButton()
    var styled = false
    var commentsAction: (() -> ())?

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
        contentView.addSubview(authorLabel)
        contentView.addSubview(upvoteButton)
        contentView.addSubview(downvoteButton)
        contentView.addSubview(commentsButton)
        
        commentsButton.addTarget(self, action: Selector("commentsAction:"), forControlEvents: .TouchUpInside)
    }
    
    func commentsAction(sender: UIButton) {
        if let action = commentsAction {
            action()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        commentsAction = nil
    }
    
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
