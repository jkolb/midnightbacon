//
//  ThingAgeFormatter.swift
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

import Foundation

public class ThingAgeFormatter : NSFormatter {
    let calendar: NSCalendar
    
    public convenience override init() {
        self.init(calendar: NSCalendar.currentCalendar())
    }
    
    public init(calendar: NSCalendar) {
        self.calendar = calendar
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.calendar = NSCalendar.currentCalendar()
        super.init(coder: aDecoder)
    }
    
    public func stringForDate(date: NSDate) -> String? {
        return stringForObjectValue(date)
    }
    
    public override func stringForObjectValue(obj: AnyObject) -> String? {
        if let date = obj as? NSDate {
            let now = NSDate()
            let components = calendar.components([.Year, .Month, .WeekOfMonth, .Day, .Hour, .Minute, .Second],
                fromDate: date,
                toDate: now,
                options: .WrapComponents
            )
            
            if components.year == 0 {
                if components.month == 0 {
                    if components.weekOfMonth == 0 {
                        if components.day == 0 {
                            if components.hour == 0 {
                                if components.minute == 0 {
                                    if components.second == 0 {
                                        return "just now"
                                    } else if components.second == 1 {
                                        return "\(components.second) second ago"
                                    } else {
                                        return "\(components.second) seconds ago"
                                    }
                                } else if components.minute == 1 {
                                    return "\(components.minute) minute ago"
                                } else {
                                    return "\(components.minute) minutes ago"
                                }
                            } else if components.hour == 1 {
                                return "\(components.hour) hour ago"
                            } else {
                                return "\(components.hour) hours ago"
                            }
                        } else if components.day == 1 {
                            return "\(components.day) day ago"
                        } else {
                            return "\(components.day) days ago"
                        }
                    } else if components.weekOfMonth == 1 {
                        return "\(components.weekOfMonth) week ago"
                    } else {
                        return "\(components.weekOfMonth) weeks ago"
                    }
                } else if components.month == 1 {
                    return "\(components.month) month ago"
                } else {
                    return "\(components.month) months ago"
                }
            } else if components.year == 1 {
                return "\(components.year) year ago"
            } else {
                return "\(components.year) years ago"
            }
        } else {
            return nil
        }
    }
}
