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
    static let levelName = ["NONE", "ERROR", "WARN", "INFO", "DEBUG"]
    static let processName = NSProcessInfo.processInfo().processName
    static let queue = dispatch_queue_create("net.franticapparatus.Logger", DISPATCH_QUEUE_SERIAL)
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    init(level: Level) {
        self.level = level
    }
    
    private func log(message: () -> String, level: Level, file: String, line: Int) {
        if level > self.level { return }
        let date = NSDate()
        let threadID = pthread_mach_thread_np(pthread_self())
        dispatch_async(Logger.queue) {
            println("\(Logger.dateFormatter.stringFromDate(date)) \(Logger.levelName[level.rawValue]) \(Logger.processName)[\(threadID)] \(file.lastPathComponent):\(line) \(message())")
        }
    }
    
    func error(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Error, file: file, line: line)
    }
    
    func error(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Error, file: file, line: line)
    }
    
    func warn(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Warn, file: file, line: line)
    }
    
    func warn(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Warn, file: file, line: line)
    }
    
    func info(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Info, file: file, line: line)
    }
    
    func info(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Info, file: file, line: line)
    }
    
    func debug(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Debug, file: file, line: line)
    }
    
    func debug(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Debug, file: file, line: line)
    }
}

func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
