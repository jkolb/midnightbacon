//
//  LinkCell.swift
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

class LinkCell : UITableViewCell {
    struct Measurements {
        let horizontalSpacing = CGFloat(8.0)
        let verticalSpacing = CGFloat(8.0)
        let thumbnailSize = CGSize(width: 70.0, height: 70.0)
    }
    
    var measurements = Measurements()
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    let ageLabel = UILabel()
    let separatorView = UIView()
    var insets = UIEdgeInsetsZero
    var separatorHeight: CGFloat = 0.0
    var styled = false
    
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
        contentView.addSubview(ageLabel)
        contentView.addSubview(separatorView)
        
//        titleLabel.layer.borderColor = UIColor.redColor().CGColor
//        titleLabel.layer.borderWidth = 1.0
//        
//        authorLabel.layer.borderColor = UIColor.greenColor().CGColor
//        authorLabel.layer.borderWidth = 1.0
//        
//        ageLabel.layer.borderColor = UIColor.blueColor().CGColor
//        ageLabel.layer.borderWidth = 1.0
    }
}
