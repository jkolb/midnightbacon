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

func centerX(rect: CGRect) -> CGFloat {
    return CGRectGetMidX(rect)
}

func centerY(rect: CGRect) -> CGFloat {
    return CGRectGetMidY(rect)
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

class Layout {
    let equalTo: CGFloat
    let constant: CGFloat
    let multiplier: CGFloat
    
    init(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat) {
        self.equalTo = equalTo
        self.constant = constant
        self.multiplier = multiplier
    }
    
    convenience init(equalTo: CGFloat) {
        self.init(equalTo: equalTo, multiplier: 1.0, constant: 0.0)
    }

    convenience init(equalTo: CGFloat, constant: CGFloat) {
        self.init(equalTo: equalTo, multiplier: 1.0, constant: constant)
    }
    
    var value: CGFloat {
        return equalTo * multiplier + constant
    }
}

protocol Horizontal {
    func left(width: CGFloat) -> CGFloat
}

protocol Vertical {
    func top(height: CGFloat) -> CGFloat
}

protocol Typographic {
    func top(# ascender: CGFloat, descender: CGFloat, capHeight: CGFloat, xHeight: CGFloat, lineHeight: CGFloat) -> CGFloat
}

protocol Size {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize
}

final class Left : Layout, Horizontal {
    func left(width: CGFloat) -> CGFloat {
        return value
    }
}

final class Right : Layout, Horizontal {
    func left(width: CGFloat) -> CGFloat {
        return value - width
    }
}

final class CenterX : Layout, Horizontal {
    func left(width: CGFloat) -> CGFloat {
        return value - width / 2.0
    }
}

final class Leading : Layout, Horizontal {
    func left(width: CGFloat) -> CGFloat {
        return value - width / 2.0
    }
}

final class Trailing : Layout, Horizontal {
    func left(width: CGFloat) -> CGFloat {
        return value - width / 2.0
    }
}

final class Top : Layout, Vertical {
    func top(height: CGFloat) -> CGFloat {
        return value
    }
}

final class Bottom : Layout, Vertical {
    func top(height: CGFloat) -> CGFloat {
        return value - height
    }
}

final class CenterY : Layout, Vertical {
    func top(height: CGFloat) -> CGFloat {
        return value - height / 2.0
    }
}

final class Baseline : Layout, Typographic {
    func top(# ascender: CGFloat, descender: CGFloat, capHeight: CGFloat, xHeight: CGFloat, lineHeight: CGFloat) -> CGFloat {
        let baselineOffsetFromTop = round(ascender)
        return value - baselineOffsetFromTop
    }
}

final class FirstBaseline : Layout, Typographic {
    func top(# ascender: CGFloat, descender: CGFloat, capHeight: CGFloat, xHeight: CGFloat, lineHeight: CGFloat) -> CGFloat {
        let baselineOffsetFromTop = round(ascender)
        return value - baselineOffsetFromTop
    }
}

final class Capline : Layout, Typographic {
    func top(# ascender: CGFloat, descender: CGFloat, capHeight: CGFloat, xHeight: CGFloat, lineHeight: CGFloat) -> CGFloat {
        let caplineOffsetFromTop = round(ascender - capHeight)
        return value - caplineOffsetFromTop
    }
}

final class Width : Layout, Size {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let width = value
        let s = sizeThatFits(fixedWidth(width))
        return CGSize(width: width, height: s.height)
    }
}

final class Height : Layout, Size {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let height = value
        let s = sizeThatFits(fixedHeight(height))
        return CGSize(width: s.width, height: height)
    }
}

/*
case LeftMargin
case RightMargin
case TopMargin
case BottomMargin
case LeadingMargin
case TrailingMargin
case CenterXWithinMargins
case CenterYWithinMargins
*/

extension UIView {
    final func layout(horizontal: Horizontal, _ vertical: Vertical) -> CGRect {
        let s = sizeThatFits(maximumSize())
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }

    final func layout(horizontal: Horizontal, _ vertical: Vertical, _ width: Width) -> CGRect {
        let s = width.size(sizeThatFits)
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(horizontal: Horizontal, _ vertical: Vertical, _ height: Height) -> CGRect {
        let s = height.size(sizeThatFits)
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(left: Left, _ right: Right, _ vertical: Vertical) -> CGRect {
        let l = left.value
        let r = right.value
        let w = abs(r - l)
        let h = sizeThatFits(fixedWidth(w)).height
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(left: Left, _ right: Right, _ vertical: Vertical, _ height: Height) -> CGRect {
        let l = left.value
        let r = right.value
        let h = height.value
        let t = vertical.top(h)
        let w = abs(r - l)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(horizontal: Horizontal, _ vertical: Vertical, _ width: Width, _ height: Height) -> CGRect {
        let w = width.value
        let h = height.value
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(left: Left, _ right: Right, _ top: Top, _ bottom: Bottom) -> CGRect {
        let l = left.value
        let r = right.value
        let t = top.value
        let b = bottom.value
        let w = abs(r - l)
        let h = abs(b - t)
        return CGRect(x: l, y: t, width: w, height: h)
    }
}

extension UILabel {
    final func layout(horizontal: Horizontal, _ typographic: Typographic) -> CGRect {
        let s = sizeThatFits(maximumSize())
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let f = font
        let t = typographic.top(
            ascender: f.ascender,
            descender: f.descender,
            capHeight: f.capHeight,
            xHeight: f.xHeight,
            lineHeight: f.lineHeight
        )
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(left: Left, _ right: Right, _ typographic: Typographic) -> CGRect {
        let l = left.value
        let r = right.value
        let w = abs(r - l)
        let h = sizeThatFits(fixedWidth(w)).height
        let f = font
        let t = typographic.top(
            ascender: f.ascender,
            descender: f.descender,
            capHeight: f.capHeight,
            xHeight: f.xHeight,
            lineHeight: f.lineHeight
        )
        return CGRect(x: l, y: t, width: w, height: h)
    }
}
