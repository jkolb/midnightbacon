//
//  ThingAgeFormatter.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
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
    
    public required init(coder aDecoder: NSCoder) {
        self.calendar = NSCalendar.currentCalendar()
        super.init(coder: aDecoder)
    }
    
    public func stringForDate(date: NSDate) -> String? {
        return stringForObjectValue(date)
    }
    
    public override func stringForObjectValue(obj: AnyObject) -> String? {
        if let date = obj as? NSDate {
            let now = NSDate()
            let components = calendar.components(
                NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitWeekOfMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond,
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
