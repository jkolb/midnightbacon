//
//  SegmentedControlHeader.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/29/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
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
