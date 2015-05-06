//
//  SwitchTableViewCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/30/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class SwitchTableViewCell : UITableViewCell {
    let titleLabel = UILabel()
    let switchControl = UISwitch()
    let separatorView = UIView()
    let insets = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)
    var separatorHeight: CGFloat = 0.0

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        contentView.addSubview(separatorView)
    }
    
    deinit {
        switchControl.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        switchControl.on = false
        switchControl.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(contentView.bounds)
        titleLabel.frame = layout.titleLabelFrame
        switchControl.frame = layout.switchControlFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let switchSize = switchControl.sizeThatFits(size)
        let fitSize = CGSize(width: size.width, height: switchSize.height + insets.top + insets.bottom)
        return fitSize
    }
    
    private struct ViewLayout {
        let titleLabelFrame: CGRect
        let switchControlFrame: CGRect
        let separatorFrame: CGRect
    }
    
    private func generateLayout(bounds: CGRect) -> ViewLayout {
        let switchControlFrame = switchControl.layout(
            Trailing(equalTo: bounds.trailing(insets)),
            Top(equalTo: bounds.top(insets))
        )

        let titleLabelFrame = titleLabel.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: switchControlFrame.leading, constant: -8.0),
            CenterY(equalTo: switchControlFrame.centerY)
        )
        
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: switchControlFrame.bottom + insets.bottom),
            Height(equalTo: separatorHeight)
        )
        
        return ViewLayout(
            titleLabelFrame: titleLabelFrame,
            switchControlFrame: switchControlFrame,
            separatorFrame: separatorFrame
        )
    }
}
