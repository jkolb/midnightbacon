//
//  TextViewTableViewCell.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/1/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit
import DrapierLayout

class TextViewTableViewCell : UITableViewCell {
    let textView = UITextView()
    let separatorView = UIView()
    let insets = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 0.0)
    var separatorHeight: CGFloat = 0.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(textView)
        contentView.addSubview(separatorView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textView.delegate = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(contentView.bounds)
        textView.frame = layout.textViewFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let textViewSize = textView.sizeThatFits(size)
        let fitSize = CGSize(width: size.width, height: textViewSize.height + insets.top + insets.bottom)
        return fitSize
    }
    
    private struct ViewLayout {
        let textViewFrame: CGRect
        let separatorFrame: CGRect
    }
    
    private func generateLayout(bounds: CGRect) -> ViewLayout {
        let textViewFrame = textView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing(insets)),
            CenterY(equalTo: bounds.centerY(insets))
        )
        
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets)),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: textViewFrame.bottom + insets.bottom),
            Height(equalTo: separatorHeight)
        )
        
        return ViewLayout(
            textViewFrame: textViewFrame,
            separatorFrame: separatorFrame
        )
    }
}
