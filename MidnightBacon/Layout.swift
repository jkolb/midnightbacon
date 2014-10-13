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

func fixedWidth(width: CGFloat) -> CGSize {
    return CGSize(width: width, height: CGFloat.max)
}

func fixedHeight(height: CGFloat) -> CGSize {
    return CGSize(width: CGFloat.max, height: height)
}

func maximumSize() -> CGSize {
    return CGSize(width: CGFloat.max, height: CGFloat.max)
}

enum HorizontalAnchor {
    case Left(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    case Right(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    case CenterX(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    
    func originX(# width: CGFloat) -> CGFloat {
        switch self {
        case .Left(let equalTo, let multiplier, let constant):
            return (equalTo * multiplier + constant)
        case .Right(let equalTo, let multiplier, let constant):
            return (equalTo * multiplier + constant) - width
        case CenterX(let equalTo, let multiplier, let constant):
            return (equalTo * multiplier + constant) - width / 2.0
        }
    }
    
    var equalTo: CGFloat {
        switch self {
        case .Left(let equalTo, let multiplier, let constant):
            return equalTo
        case .Right(let equalTo, let multiplier, let constant):
            return equalTo
        case CenterX(let equalTo, let multiplier, let constant):
            return equalTo
        }
    }
}

enum VerticalAnchor {
    case Top(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    case Bottom(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    case CenterY(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    
    func originY(# height: CGFloat) -> CGFloat {
        switch self {
        case .Top(let equalTo, let multiplier, let constant):
            return (equalTo * multiplier + constant)
        case .Bottom(let equalTo, let multiplier, let constant):
            return (equalTo * multiplier + constant) - height
        case .CenterY(let equalTo, let multiplier, let constant):
            return (equalTo * multiplier + constant) - height / 2.0
        }
    }
}

enum LayoutSize {
    case Size(CGSize)
    case FitSize(CGSize)
    case Width(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    case Height(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat)
    
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        switch self {
        case .Size(let value):
            return value
        case .FitSize(let value):
            return sizeThatFits(value)
        case .Width(let equalTo, let multiplier, let constant):
            let width = equalTo * multiplier + constant
            let s = sizeThatFits(CGSize(width: width, height: CGFloat.max))
            return CGSize(width: width, height: s.height)
        case .Height(let equalTo, let multiplier, let constant):
            let height = equalTo * multiplier + constant
            let s = sizeThatFits(CGSize(width: CGFloat.max, height: height))
            return CGSize(width: s.width, height: height)
        }
    }
}

extension UIView {
    func layout(hAnchor: HorizontalAnchor, _ vAnchor: VerticalAnchor, _ lSize: LayoutSize) -> CGRect {
        let size = lSize.size(sizeThatFits)
        return CGRect(
            x: hAnchor.originX(width: size.width),
            y: vAnchor.originY(height: size.height),
            width: size.width,
            height: size.height
        )
    }
    
    func layout(# left: CGFloat, right: CGFloat, _ vAnchor: VerticalAnchor) -> CGRect {
        let width = right - left
        let size = sizeThatFits(fixedWidth(width))
        return CGRect(
            x: left,
            y: vAnchor.originY(height: size.height),
            width: width,
            height: size.height
        )
    }
}
