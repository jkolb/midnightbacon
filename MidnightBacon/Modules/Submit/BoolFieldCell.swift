//
//  SwitchTableViewCell.swift
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

class BoolFieldCell : UITableViewCell {
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
