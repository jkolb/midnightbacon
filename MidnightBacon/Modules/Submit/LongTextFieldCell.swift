//
//  TextViewTableViewCell.swift
//  MidnightBacon
//
// Copyright (c) 2015 Justin Kolb - http://franticapparatus.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
    
    required init?(coder aDecoder: NSCoder) {
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
