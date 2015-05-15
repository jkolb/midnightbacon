//
//  CommentCell.swift
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

class CommentCell : UITableViewCell {
    let authorLabel = UILabel()
    let bodyLabel = UILabel()
    let indentionView = UIView()
    let separatorView = UIView()
    var insets = UIEdgeInsetsZero
    var separatorHeight: CGFloat = 0.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.opaque = true
        
        contentView.addSubview(bodyLabel)
        contentView.addSubview(authorLabel)
//        contentView.addSubview(indentionView)
        contentView.addSubview(separatorView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    struct CellLayout {
        let authorFrame: CGRect
        let bodyFrame: CGRect
        let indentionFrame: CGRect
        let separatorFrame: CGRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = generateLayout(contentView.bounds)
        authorLabel.frame = layout.authorFrame
        bodyLabel.frame = layout.bodyFrame
        indentionView.frame = layout.indentionFrame
        separatorView.frame = layout.separatorFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let layout = generateLayout(size.rect())
        let maxBottom = layout.bodyFrame.bottom
        return CGSize(width: size.width, height: maxBottom + insets.bottom)
    }
    
    func generateLayout(bounds: CGRect) -> CellLayout {
        let indent = CGFloat(indentationLevel) * CGFloat(4.0)
        let authorFrame = authorLabel.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: bounds.top(insets))
        )
        let bodyFrame = bodyLabel.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent),
            Trailing(equalTo: bounds.trailing(insets)),
            Capline(equalTo: authorFrame.baseline(font: authorLabel.font), constant: CGFloat(8.0))
        )
        let indentionFrame = indentionView.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent - CGFloat(8.0)),
            Top(equalTo: bounds.top),
            Width(equalTo: separatorHeight),
            Height(equalTo: bounds.height)
        )
        let separatorFrame = separatorView.layout(
            Leading(equalTo: bounds.leading(insets), constant: indent),
            Trailing(equalTo: bounds.trailing),
            Bottom(equalTo: bodyFrame.bottom + insets.bottom),
            Height(equalTo: separatorHeight)
        )
        return CellLayout(
            authorFrame: authorFrame,
            bodyFrame: bodyFrame,
            indentionFrame: indentionFrame,
            separatorFrame: separatorFrame
        )
    }
}
