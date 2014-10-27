//
//  Layout.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/12/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit

let maximumLayoutValue = CGFloat(10_000.0)

extension CGSize {
    func rect() -> CGRect {
        return CGRect(origin: CGPointZero, size: self)
    }
    
    static func fixedWidth(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: maximumLayoutValue)
    }
    
    static func fixedHeight(height: CGFloat) -> CGSize {
        return CGSize(width: maximumLayoutValue, height: height)
    }
    
    static var maximum: CGSize {
        return CGSize(width: maximumLayoutValue, height: maximumLayoutValue)
    }
}

extension CGRect {
    var top: CGFloat {
        return CGRectGetMinY(self)
    }
    
    func top(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinY(self) + margins.top
    }
    
    var left: CGFloat {
        return CGRectGetMinX(self)
    }
    
    func left(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinX(self) + margins.left
    }
    
    var bottom: CGFloat {
        return CGRectGetMaxY(self)
    }
    
    func bottom(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMaxY(self) - margins.bottom
    }
    
    var right: CGFloat {
        return CGRectGetMaxX(self)
    }
    
    func right(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMaxX(self) - margins.right
    }
    
    var centerY: CGFloat {
        return CGRectGetMidY(self)
    }

    func centerY(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinY(self) + margins.top + ((CGRectGetHeight(self) - margins.top - margins.bottom) / 2.0)
    }
    
    var centerX: CGFloat {
        return CGRectGetMidX(self)
    }
    
    func centerX(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinX(self) + margins.left + ((CGRectGetWidth(self) - margins.left - margins.right) / 2.0)
    }
    
    var width: CGFloat {
        return CGRectGetWidth(self)
    }
    
    var height: CGFloat {
        return CGRectGetHeight(self)
    }
    
    var leading: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return self.left
        case .RightToLeft:
            return self.right
        }
    }
    
    func leading(margins: UIEdgeInsets) -> CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return self.left(margins)
        case .RightToLeft:
            return self.right(margins)
        }
    }
    
    var trailing: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return self.right
        case .RightToLeft:
            return self.left
        }
    }
    
    func trailing(margins: UIEdgeInsets) -> CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return self.right(margins)
        case .RightToLeft:
            return self.left(margins)
        }
    }
    
    func baseline(# descender: CGFloat) -> CGFloat {
        return round(self.bottom + descender)
    }
    
    func baseline(font: UIFont) -> CGFloat {
        return baseline(descender: font.descender)
    }
    
    func baseline(label: UILabel) -> CGFloat {
        return baseline(label.font)
    }
    
    func firstBaseline(# ascender: CGFloat) -> CGFloat {
        return round(self.top + ascender)
    }
    
    func firstBaseline(font: UIFont) -> CGFloat {
        return firstBaseline(ascender: font.ascender)
    }
    
    func firstBaseline(label: UILabel) -> CGFloat {
        return firstBaseline(label.font)
    }
    
    func capline(# ascender: CGFloat, capHeight: CGFloat) -> CGFloat {
        return round(self.top + (ascender - capHeight))
    }
    
    func capline(font: UIFont) -> CGFloat {
        return capline(ascender: font.ascender, capHeight: font.capHeight)
    }
    
    func capline(label: UILabel) -> CGFloat {
        return capline(label.font)
    }
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
    func top(height: CGFloat, offset: CGFloat) -> CGFloat
    func offset(font: UIFont) -> CGFloat
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
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return value
        case .RightToLeft:
            return value - width
        }
    }
    
    override var value: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return equalTo * multiplier + constant
        case .RightToLeft:
            return equalTo * multiplier - constant
        }
    }
}

final class Trailing : Layout, Horizontal {
    func left(width: CGFloat) -> CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return value - width
        case .RightToLeft:
            return value
        }
    }
    
    override var value: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return equalTo * multiplier + constant
        case .RightToLeft:
            return equalTo * multiplier - constant
        }
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
    func top(height: CGFloat, offset: CGFloat) -> CGFloat {
        return round((value - height) - offset)
    }
    
    func offset(font: UIFont) -> CGFloat {
        return font.descender
    }
}

final class FirstBaseline : Layout, Typographic {
    func top(height: CGFloat, offset: CGFloat) -> CGFloat {
        return round(value - offset)
    }
    
    func offset(font: UIFont) -> CGFloat {
        return font.ascender
    }
}

final class Capline : Layout, Typographic {
    func top(height: CGFloat, offset: CGFloat) -> CGFloat {
        return round(value - offset)
    }
    
    func offset(font: UIFont) -> CGFloat {
        return font.ascender - font.capHeight
    }
}

final class Width : Layout, Size {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let width = value
        let s = sizeThatFits(CGSize.fixedWidth(width))
        return CGSize(width: width, height: s.height)
    }
}

final class Height : Layout, Size {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let height = value
        let s = sizeThatFits(CGSize.fixedHeight(height))
        return CGSize(width: s.width, height: height)
    }
}

extension UIView {
    final func layout(horizontal: Horizontal, _ vertical: Vertical) -> CGRect {
        let s = sizeThatFits(CGSize.maximum)
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
        let h = sizeThatFits(CGSize.fixedWidth(w)).height
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
    
    final func layout(leading: Leading, _ trailing: Trailing, _ vertical: Vertical, _ height: Height) -> CGRect {
        let l = leading.value
        let r = trailing.value
        let h = height.value
        let t = vertical.top(h)
        let x0 = min(l, r)
        let x1 = max(l, r)
        let w = abs(x1 - x0)
        return CGRect(x: x0, y: t, width: w, height: h)
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
        let s = sizeThatFits(CGSize.maximum)
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = typographic.top(h, offset: typographic.offset(font))
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(left: Left, _ right: Right, _ typographic: Typographic) -> CGRect {
        let l = left.value
        let r = right.value
        let w = abs(r - l)
        let h = sizeThatFits(CGSize.fixedWidth(w)).height
        let t = typographic.top(h, offset: typographic.offset(font))
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    final func layout(leading: Leading, _ trailing: Trailing, _ typographic: Typographic) -> CGRect {
        let l = leading.value
        let r = trailing.value
        let x0 = min(l, r)
        let x1 = max(l, r)
        let w = abs(x1 - x0)
        let h = sizeThatFits(CGSize.fixedWidth(w)).height
        let t = typographic.top(h, offset: typographic.offset(font))
        return CGRect(x: x0, y: t, width: w, height: h)
    }
}
