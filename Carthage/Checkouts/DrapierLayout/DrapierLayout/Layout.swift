// Copyright (c) 2016 Justin Kolb - http://franticapparatus.net
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

import UIKit

public let maximumLayoutValue = CGFloat(10_000.0)

public extension CGSize {
    public func rect() -> CGRect {
        return CGRect(origin: CGPoint.zero, size: self)
    }
    
    public static func fixedWidth(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: maximumLayoutValue)
    }
    
    public static func fixedHeight(height: CGFloat) -> CGSize {
        return CGSize(width: maximumLayoutValue, height: height)
    }
    
    public static var maximum: CGSize {
        return CGSize(width: maximumLayoutValue, height: maximumLayoutValue)
    }
}

public extension CGRect {
    public var top: CGFloat {
        return CGRectGetMinY(self)
    }
    
    public func top(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinY(self) + margins.top
    }
    
    public var left: CGFloat {
        return CGRectGetMinX(self)
    }
    
    public func left(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinX(self) + margins.left
    }
    
    public var bottom: CGFloat {
        return CGRectGetMaxY(self)
    }
    
    public func bottom(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMaxY(self) - margins.bottom
    }
    
    public var right: CGFloat {
        return CGRectGetMaxX(self)
    }
    
    public func right(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMaxX(self) - margins.right
    }
    
    public var centerY: CGFloat {
        return CGRectGetMidY(self)
    }

    public func centerY(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinY(self) + margins.top + ((CGRectGetHeight(self) - margins.top - margins.bottom) / 2.0)
    }
    
    public var centerX: CGFloat {
        return CGRectGetMidX(self)
    }
    
    public func centerX(margins: UIEdgeInsets) -> CGFloat {
        return CGRectGetMinX(self) + margins.left + ((CGRectGetWidth(self) - margins.left - margins.right) / 2.0)
    }
    
    public var leading: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return left
        case .RightToLeft:
            return right
        }
    }
    
    public func leading(margins: UIEdgeInsets) -> CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return left(margins)
        case .RightToLeft:
            return right(margins)
        }
    }
    
    public var trailing: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return right
        case .RightToLeft:
            return left
        }
    }
    
    public func trailing(margins: UIEdgeInsets) -> CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return right(margins)
        case .RightToLeft:
            return left(margins)
        }
    }
    
    public func baseline(descender descender: CGFloat) -> CGFloat {
        return round(bottom + descender)
    }
    
    public func baseline(font font: UIFont) -> CGFloat {
        return baseline(descender: font.descender)
    }
    
    public func firstBaseline(ascender ascender: CGFloat) -> CGFloat {
        return round(top + ascender)
    }
    
    public func firstBaseline(font font: UIFont) -> CGFloat {
        return firstBaseline(ascender: font.ascender)
    }
    
    public func capline(ascender ascender: CGFloat, capHeight: CGFloat) -> CGFloat {
        return round(top + (ascender - capHeight))
    }
    
    public func capline(font font: UIFont) -> CGFloat {
        return capline(ascender: font.ascender, capHeight: font.capHeight)
    }
    
    public var aspectRatio: CGFloat {
        return width / height
    }
    
    public var inverseAspectRatio: CGFloat {
        return height / width
    }
}

public class Layout {
    let equalTo: CGFloat
    let constant: CGFloat
    let multiplier: CGFloat
    
    public init(equalTo: CGFloat, multiplier: CGFloat, constant: CGFloat) {
        self.equalTo = equalTo
        self.constant = constant
        self.multiplier = multiplier
    }
    
    public convenience init(equalTo: CGFloat) {
        self.init(equalTo: equalTo, multiplier: 1.0, constant: 0.0)
    }

    public convenience init(equalTo: CGFloat, constant: CGFloat) {
        self.init(equalTo: equalTo, multiplier: 1.0, constant: constant)
    }
    
    public var value: CGFloat {
        return equalTo * multiplier + constant
    }
}

public protocol Horizontal {
    func left(width: CGFloat) -> CGFloat
}

public protocol Vertical {
    func top(height: CGFloat) -> CGFloat
}

public protocol Typographic {
    func top(height: CGFloat, offset: CGFloat) -> CGFloat
    func offset(font: UIFont) -> CGFloat
}

public protocol Size {
    func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize
}

public final class Left : Layout, Horizontal {
    public func left(width: CGFloat) -> CGFloat {
        return value
    }
}

public final class Right : Layout, Horizontal {
    public func left(width: CGFloat) -> CGFloat {
        return value - width
    }
}

public final class CenterX : Layout, Horizontal {
    public func left(width: CGFloat) -> CGFloat {
        return value - width / 2.0
    }
}

public final class Leading : Layout, Horizontal {
    public func left(width: CGFloat) -> CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return value
        case .RightToLeft:
            return value - width
        }
    }
    
    public override var value: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return equalTo * multiplier + constant
        case .RightToLeft:
            return equalTo * multiplier - constant
        }
    }
}

public final class Trailing : Layout, Horizontal {
    public func left(width: CGFloat) -> CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return value - width
        case .RightToLeft:
            return value
        }
    }
    
    public override var value: CGFloat {
        switch UIApplication.sharedApplication().userInterfaceLayoutDirection {
        case .LeftToRight:
            return equalTo * multiplier + constant
        case .RightToLeft:
            return equalTo * multiplier - constant
        }
    }
}

public final class Top : Layout, Vertical {
    public func top(height: CGFloat) -> CGFloat {
        return value
    }
}

public final class Bottom : Layout, Vertical {
    public func top(height: CGFloat) -> CGFloat {
        return value - height
    }
}

public final class CenterY : Layout, Vertical {
    public func top(height: CGFloat) -> CGFloat {
        return value - height / 2.0
    }
}

public final class Baseline : Layout, Typographic {
    public func top(height: CGFloat, offset: CGFloat) -> CGFloat {
        return round((value - height) - offset)
    }
    
    public func offset(font: UIFont) -> CGFloat {
        return font.descender
    }
}

public final class FirstBaseline : Layout, Typographic {
    public func top(height: CGFloat, offset: CGFloat) -> CGFloat {
        return round(value - offset)
    }
    
    public func offset(font: UIFont) -> CGFloat {
        return font.ascender
    }
}

public final class Capline : Layout, Typographic {
    public func top(height: CGFloat, offset: CGFloat) -> CGFloat {
        return round(value - offset)
    }
    
    public func offset(font: UIFont) -> CGFloat {
        return font.ascender - font.capHeight
    }
}

public final class Width : Layout, Size {
    public func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let width = value
        let s = sizeThatFits(CGSize.fixedWidth(width))
        return CGSize(width: width, height: s.height)
    }
}

public final class Height : Layout, Size {
    public func size(sizeThatFits: (CGSize) -> CGSize) -> CGSize {
        let height = value
        let s = sizeThatFits(CGSize.fixedHeight(height))
        return CGSize(width: s.width, height: height)
    }
}

public extension UIView {
    public final func layout(horizontal: Horizontal, _ vertical: Vertical) -> CGRect {
        let s = sizeThatFits(CGSize.maximum)
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }

    public final func layout(horizontal: Horizontal, _ vertical: Vertical, _ width: Width) -> CGRect {
        let s = width.size(sizeThatFits)
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(horizontal: Horizontal, _ vertical: Vertical, _ height: Height) -> CGRect {
        let s = height.size(sizeThatFits)
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(left: Left, _ right: Right, _ vertical: Vertical) -> CGRect {
        let l = left.value
        let r = right.value
        let w = abs(r - l)
        let h = sizeThatFits(CGSize.fixedWidth(w)).height
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(leading: Leading, _ trailing: Trailing, _ vertical: Vertical) -> CGRect {
        let l = leading.value
        let r = trailing.value
        let x0 = min(l, r)
        let x1 = max(l, r)
        let w = abs(x1 - x0)
        let h = sizeThatFits(CGSize.fixedWidth(w)).height
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(left: Left, _ right: Right, _ vertical: Vertical, _ height: Height) -> CGRect {
        let l = left.value
        let r = right.value
        let h = height.value
        let t = vertical.top(h)
        let w = abs(r - l)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(leading: Leading, _ trailing: Trailing, _ vertical: Vertical, _ height: Height) -> CGRect {
        let l = leading.value
        let r = trailing.value
        let h = height.value
        let t = vertical.top(h)
        let x0 = min(l, r)
        let x1 = max(l, r)
        let w = abs(x1 - x0)
        return CGRect(x: x0, y: t, width: w, height: h)
    }
    
    public final func layout(horizontal: Horizontal, _ vertical: Vertical, _ width: Width, _ height: Height) -> CGRect {
        let w = width.value
        let h = height.value
        let l = horizontal.left(w)
        let t = vertical.top(h)
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(left: Left, _ right: Right, _ top: Top, _ bottom: Bottom) -> CGRect {
        let l = left.value
        let r = right.value
        let t = top.value
        let b = bottom.value
        let w = abs(r - l)
        let h = abs(b - t)
        return CGRect(x: l, y: t, width: w, height: h)
    }
}

public extension UILabel {
    public final func layout(horizontal: Horizontal, _ typographic: Typographic) -> CGRect {
        let s = sizeThatFits(CGSize.maximum)
        let w = s.width
        let h = s.height
        let l = horizontal.left(w)
        let t = typographic.top(h, offset: typographic.offset(font))
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(left: Left, _ right: Right, _ typographic: Typographic) -> CGRect {
        let l = left.value
        let r = right.value
        let w = abs(r - l)
        let h = sizeThatFits(CGSize.fixedWidth(w)).height
        let t = typographic.top(h, offset: typographic.offset(font))
        return CGRect(x: l, y: t, width: w, height: h)
    }
    
    public final func layout(leading: Leading, _ trailing: Trailing, _ typographic: Typographic) -> CGRect {
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
