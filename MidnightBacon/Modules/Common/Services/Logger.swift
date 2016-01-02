//
//  Logger.swift
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

public class Logger {
    public enum Level : Int, Comparable {
        case None
        case Error
        case Warn
        case Info
        case Debug
    }
    
    public let level: Level
    static let levelName = ["NONE", "ERROR", "WARN", "INFO", "DEBUG"]
    static let processName = NSProcessInfo.processInfo().processName
    static let queue = dispatch_queue_create("net.franticapparatus.Logger", DISPATCH_QUEUE_SERIAL)
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    public init(level: Level) {
        self.level = level
    }
    
    private func log(message: () -> String, level: Level, file: String, line: Int) {
        if level > self.level { return }
        let date = NSDate()
        let threadID = pthread_mach_thread_np(pthread_self())
        dispatch_async(Logger.queue) {
            print("\(Logger.dateFormatter.stringFromDate(date)) \(Logger.levelName[level.rawValue]) \(Logger.processName)[\(threadID)] \(file):\(line) \(message())")
        }
    }
    
    public func error(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Error, file: file, line: line)
    }
    
    public func error(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Error, file: file, line: line)
    }
    
    public func warn(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Warn, file: file, line: line)
    }
    
    public func warn(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Warn, file: file, line: line)
    }
    
    public func info(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Info, file: file, line: line)
    }
    
    public func info(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Info, file: file, line: line)
    }
    
    public func debug(@autoclosure(escaping) message: () -> String, file: String = __FILE__, line: Int = __LINE__) {
        log(message, level: .Debug, file: file, line: line)
    }
    
    public func debug(file: String = __FILE__, line: Int = __LINE__, message: () -> String) {
        log(message, level: .Debug, file: file, line: line)
    }
}

public func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
