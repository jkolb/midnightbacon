//
//  SegmentedControlHeader.swift
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

protocol SegmentedControlHeaderDelegate : class {
    func numberOfSegmentsInSegmentedControlHeader(segmentedControlHeader: SegmentedControlHeader) -> Int
    func selectedIndexOfSegmentedControlHeader(segmentedControlHeader: SegmentedControlHeader) -> Int
    func segmentedControlHeader(segmentedControlHeader: SegmentedControlHeader, titleForSegmentAtIndex index: Int) -> String
}

class SegmentedControlHeader : UIView {
    weak var delegate: SegmentedControlHeaderDelegate?
    let segmentedControl = UISegmentedControl()
    let insets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(segmentedControl)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(segmentedControl)
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        
        if newWindow == nil {
            segmentedControl.removeAllSegments()
        } else {
            if let delegate = self.delegate {
                let numberOfSegments = delegate.numberOfSegmentsInSegmentedControlHeader(self)
                for var i = 0; i < numberOfSegments; ++i {
                    let title = delegate.segmentedControlHeader(self, titleForSegmentAtIndex: i)
                    segmentedControl.insertSegmentWithTitle(title, atIndex: i, animated: false)
                }
                segmentedControl.selectedSegmentIndex = delegate.selectedIndexOfSegmentedControlHeader(self)
                addSubview(segmentedControl)
            } else {
                segmentedControl.removeAllSegments()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = generateLayout(bounds)
        segmentedControl.frame = layout.segmentedControlFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let segmentedSize = segmentedControl.sizeThatFits(size)
        let fitSize = CGSize(width: size.width, height: segmentedSize.height + insets.top + insets.bottom)
        return fitSize
    }
    
    private struct ViewLayout {
        let segmentedControlFrame: CGRect
    }
    
    private func generateLayout(bounds: CGRect) -> ViewLayout {
        let segmentedControlFrame = segmentedControl.layout(
            Left(equalTo: bounds.left(insets)),
            Right(equalTo: bounds.right(insets)),
            CenterY(equalTo: bounds.centerY(insets))
        )
        
        return ViewLayout(
            segmentedControlFrame: segmentedControlFrame
        )
    }
}
