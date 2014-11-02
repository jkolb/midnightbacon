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
}
