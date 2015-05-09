//
//  TextViewTableViewCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/1/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class LongTextFieldCell : UITableViewCell {
    let textField = UITextField()
    let disclosureLabel = UILabel()
    let separatorView = UIView()
    let insets = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)
    var separatorHeight: CGFloat = 0.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        contentView.addSubview(disclosureLabel)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(textField)
        contentView.addSubview(disclosureLabel)
        contentView.addSubview(separatorView)
    }
    
    deinit {
        textField.delegate = nil
        textField.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.delegate = nil
        textField.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(contentView.bounds)
        textField.frame = layout.textFieldFrame
        disclosureLabel.frame = layout.disclosureFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let fitSize = CGSizeMake(size.width, layout.separatorFrame.bottom)
        return fitSize
    }
    
    private struct ViewLayout {
        let textFieldFrame: CGRect
        let disclosureFrame: CGRect
        let separatorFrame: CGRect
    }
    
    private func generateLayout(bounds: CGRect) -> ViewLayout {
        var textFieldFrame = textField.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing(insets)),
            Top(equalTo: bounds.top(insets))
        )
        
        let disclosureFrame = disclosureLabel.layout(
            Trailing(equalTo: bounds.trailing(insets)),
            CenterY(equalTo: textFieldFrame.centerY)
        )
        
        textFieldFrame = textField.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: disclosureFrame.leading, constant: -8.0),
            Top(equalTo: bounds.top(insets))
        )
        
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: textFieldFrame.bottom + insets.bottom),
            Height(equalTo: separatorHeight)
        )
        
        return ViewLayout(
            textFieldFrame: textFieldFrame,
            disclosureFrame: disclosureFrame,
            separatorFrame: separatorFrame
        )
    }
}
