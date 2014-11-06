//
//  LinkCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/2/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

class LinkCell : UITableViewCell {
    struct Measurements {
        let voteSize = CGSize(width: 24.0, height: 24.0)
        let horizontalSpacing = CGFloat(8.0)
        let verticalSpacing = CGFloat(8.0)
        let buttonHeight = CGFloat(24.0)
        let thumbnailSize = CGSize(width: 52.0, height: 52.0)
    }
    
    var measurements = Measurements()
    let titleLabel = UILabel()
    let upvoteButton = UIButton()
    let downvoteButton = UIButton()
    let authorLabel = UILabel()
    let commentsButton = UIButton()
    var styled = false
    var commentsAction: (() -> ())?
    var upvoteAction: (() -> ())?
    var downvoteAction: (() -> ())?
    
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
        upvoteButton.addTarget(self, action: Selector("upvoteAction:"), forControlEvents: .TouchUpInside)
        downvoteButton.addTarget(self, action: Selector("downvoteAction:"), forControlEvents: .TouchUpInside)
    }
    
    func commentsAction(sender: UIButton) {
        if let action = commentsAction {
            action()
        }
    }
    
    func upvoteAction(sender: UIButton) {
        upvoteButton.selected = !upvoteButton.selected
        
        if upvoteButton.selected {
            upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Selected)?.CGColor
        } else {
            upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Normal)?.CGColor
        }

        downvoteButton.selected = false
        downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Normal)?.CGColor

        if let action = upvoteAction {
            action()
        }
    }
    
    func downvoteAction(sender: UIButton) {
        downvoteButton.selected = !downvoteButton.selected
        
        if downvoteButton.selected {
            downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Selected)?.CGColor
        } else {
            downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Normal)?.CGColor
        }

        upvoteButton.selected = false
        upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Normal)?.CGColor

        if let action = downvoteAction {
            action()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        upvoteButton.selected = false
        downvoteButton.selected = false
        
        upvoteButton.layer.borderColor = upvoteButton.titleColorForState(.Normal)?.CGColor
        downvoteButton.layer.borderColor = downvoteButton.titleColorForState(.Normal)?.CGColor

        commentsAction = nil
        upvoteAction = nil
        downvoteAction = nil
    }
}
