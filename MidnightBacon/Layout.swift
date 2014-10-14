//
//  Layout.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

extension CGRect {
    init(size: CGSize) {
        self.origin = CGPointZero
        self.size = size
    }
    
    func inset(insets: UIEdgeInsets) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(self, insets)
        return CGRect(
            x: max(0.0, insetRect.origin.x),
            y: max(0.0, insetRect.origin.y),
            width: max(0.0, insetRect.size.width),
            height: max(0.0, insetRect.size.height)
        )
    }
}

func top(rect: CGRect) -> CGFloat {
    return CGRectGetMinY(rect)
}

func bottom(rect: CGRect) -> CGFloat {
    return CGRectGetMaxY(rect)
}

func left(rect: CGRect) -> CGFloat {
    return CGRectGetMinX(rect)
}

func right(rect: CGRect) -> CGFloat {
    return CGRectGetMaxX(rect)
}

func width(rect: CGRect) -> CGFloat {
    return CGRectGetWidth(rect)
}

func height(rect: CGRect) -> CGFloat {
    return CGRectGetHeight(rect)
}

func fixedWidth(width: CGFloat) -> CGSize {
    return CGSize(width: width, height: CGFloat.max)
}

func fixedHeight(height: CGFloat) -> CGSize {
    return CGSize(width: CGFloat.max, height: height)
}

func maximumSize() -> CGSize {
    return CGSize(width: CGFloat.max, height: CGFloat.max)
}

class LayoutAnchor {
    let equalTo: CGFloat
    let constant: CGFloat
    let multiplier: CGFloat
    
    init(equalTo: CGFloat, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0) {
        self.equalTo = equalTo
        self.constant = constant
        self.multiplier = multiplier
    }
    
    var value: CGFloat {
        return equalTo * multiplier + constant
    }
}

protocol HorizontalAnchor {
    func originX(# width: CGFloat) -> CGFloat
}

protocol VerticalAnchor {
    func originY(# height: CGFloat) -> CGFloat
}

protocol SizeAnchor {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize
}

final class LeftAnchor : LayoutAnchor, HorizontalAnchor {
    func originX(# width: CGFloat) -> CGFloat {
        return value
    }
}

final class RightAnchor : LayoutAnchor, HorizontalAnchor {
    func originX(# width: CGFloat) -> CGFloat {
        return value - width
    }
}

final class CenterXAnchor : LayoutAnchor, HorizontalAnchor {
    func originX(# width: CGFloat) -> CGFloat {
        return value - width / 2.0
    }
}

final class TopAnchor : LayoutAnchor, VerticalAnchor {
    func originY(# height: CGFloat) -> CGFloat {
        return value
    }
}

final class BottomAnchor : LayoutAnchor, VerticalAnchor {
    func originY(# height: CGFloat) -> CGFloat {
        return value - height
    }
}

final class CenterYAnchor : LayoutAnchor, VerticalAnchor {
    func originY(# height: CGFloat) -> CGFloat {
        return value - height / 2.0
    }
}

final class WidthAnchor : LayoutAnchor, SizeAnchor {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let width = value
        let s = sizeThatFits(CGSize(width: width, height: CGFloat.max))
        return CGSize(width: width, height: s.height)
    }
}

final class HeightAnchor : LayoutAnchor, SizeAnchor {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let height = value
        let s = sizeThatFits(CGSize(width: CGFloat.max, height: height))
        return CGSize(width: s.width, height: height)
    }
}

extension UIView {
    func layout(horizontalAnchor: HorizontalAnchor, _ verticalAnchor: VerticalAnchor, _ widthAnchor: WidthAnchor) -> CGRect {
        let size = widthAnchor.size(sizeThatFits)
        return CGRect(
            x: horizontalAnchor.originX(width: size.width),
            y: verticalAnchor.originY(height: size.height),
            width: size.width,
            height: size.height
        )
    }

    func layout(horizontalAnchor: HorizontalAnchor, _ verticalAnchor: VerticalAnchor, _ heightAnchor: HeightAnchor) -> CGRect {
        let size = heightAnchor.size(sizeThatFits)
        return CGRect(
            x: horizontalAnchor.originX(width: size.width),
            y: verticalAnchor.originY(height: size.height),
            width: size.width,
            height: size.height
        )
    }

    func layout(leftAnchor: LeftAnchor, _ rightAnchor: RightAnchor, _ verticalAnchor: VerticalAnchor) -> CGRect {
        let width = abs(leftAnchor.value - rightAnchor.value)
        let size = sizeThatFits(fixedWidth(width))
        return CGRect(
            x: leftAnchor.value,
            y: verticalAnchor.originY(height: size.height),
            width: width,
            height: size.height
        )
    }
    
    func layout(leftAnchor: LeftAnchor, _ rightAnchor: RightAnchor, _ verticalAnchor: VerticalAnchor, _ heightAnchor: HeightAnchor) -> CGRect {
        let width = abs(leftAnchor.value - rightAnchor.value)
        let height = heightAnchor.value
        return CGRect(
            x: leftAnchor.value,
            y: verticalAnchor.originY(height: height),
            width: width,
            height: height
        )
    }
    
    func layout(horizontalAnchor: HorizontalAnchor, _ verticalAnchor: VerticalAnchor, _ widthAnchor: WidthAnchor, _ heightAnchor: HeightAnchor) -> CGRect {
        let width = widthAnchor.value
        let height = heightAnchor.value
        return CGRect(
            x: horizontalAnchor.originX(width: width),
            y: verticalAnchor.originY(height: height),
            width: width,
            height: height
        )
    }
}
