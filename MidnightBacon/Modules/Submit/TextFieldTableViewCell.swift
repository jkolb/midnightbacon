//
//  TextFieldTableViewCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/29/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class TextFieldTableViewCell : UITableViewCell {
    let textField = UITextField()
    let separatorView = UIView()
    let insets = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 0.0)
    var separatorHeight: CGFloat = 0.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(textField)
        contentView.addSubview(separatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(contentView.bounds)
        textField.frame = layout.textFieldFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let textFieldSize = textField.sizeThatFits(size)
        let fitSize = CGSize(width: size.width, height: textFieldSize.height + insets.top + insets.bottom)
        return fitSize
    }
    
    private struct ViewLayout {
        let textFieldFrame: CGRect
        let separatorFrame: CGRect
    }
    
    private func generateLayout(bounds: CGRect) -> ViewLayout {
        let textFieldFrame = textField.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing(insets)),
            CenterY(equalTo: bounds.centerY(insets))
        )
        
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: textFieldFrame.bottom + insets.bottom),
            Height(equalTo: separatorHeight)
        )

        return ViewLayout(
            textFieldFrame: textFieldFrame,
            separatorFrame: separatorFrame
        )
    }
}
