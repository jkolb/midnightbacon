//
//  Logger.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/19/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

class Logger {
    enum Level : Int, Comparable {
        case None
        case Error
        case Warn
        case Info
        case Debug
    }
    
    let level: Level
    lazy var queue: dispatch_queue_t = {
        return dispatch_queue_create("net.franticapparatus.Logger", DISPATCH_QUEUE_SERIAL)
    }()
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    init(level: Level) {
        self.level = level
    }
    
    private func log(message: () -> String, level: Level, levelName: String, date: NSDate, function: String, file: String, line: Int) {
        if level > self.level { return }
        let threadName = NSThread.currentThread().name
        let dateFormatter = self.dateFormatter
        dispatch_async(queue) {
            println("\(dateFormatter.stringFromDate(date)) \(levelName) \(file.lastPathComponent):\(line) \(function) : \(message())")
        }
    }
    
    func error(@autoclosure(escaping) message: () -> String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Error, levelName: "error", date: NSDate(), function: function, file: file, line: line)
    }
    
    func error(function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Error, levelName: "error", date: NSDate(), function: function, file: file, line: line)
    }
    
    func warn(@autoclosure(escaping) message: () -> String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Warn, levelName: "warn", date: NSDate(), function: function, file: file, line: line)
    }
    
    func warn(function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Warn, levelName: "warn", date: NSDate(), function: function, file: file, line: line)
    }
    
    func info(@autoclosure(escaping) message: () -> String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Info, levelName: "info", date: NSDate(), function: function, file: file, line: line)
    }
    
    func info(function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Info, levelName: "info", date: NSDate(), function: function, file: file, line: line)
    }
    
    func debug(@autoclosure(escaping) message: () -> String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Debug, levelName: "debug", date: NSDate(), function: function, file: file, line: line)
    }
    
    func debug(function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Debug, levelName: "debug", date: NSDate(), function: function, file: file, line: line)
    }
}

func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
