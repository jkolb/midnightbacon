//
//  DispatchQueue.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/31/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import Dispatch

public protocol DispatchQueue : class, CustomStringConvertible {
    func dispatch(block: () -> ())
    func dispatchAndWait(block: () -> ())
    func dispatchSerialized(block: () -> ())
}

public final class GCDQueue : DispatchQueue {
    let queue: dispatch_queue_t
    
    public init(queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    public class func main() -> GCDQueue {
        return GCDQueue(queue: dispatch_get_main_queue())
    }
    
    public class func serial(name: String) -> GCDQueue {
        return GCDQueue(queue: dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL))
    }
    
    public class func concurrent(name: String) -> GCDQueue {
        return GCDQueue(queue: dispatch_queue_create(name, DISPATCH_QUEUE_CONCURRENT))
    }
    
    public class func globalPriorityDefault() -> GCDQueue {
        return GCDQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
    
    public class func globalPriorityBackground() -> GCDQueue {
        return GCDQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
    }
    
    public class func globalPriorityHigh() -> GCDQueue {
        return GCDQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
    }
    
    public class func globalPriorityLow() -> GCDQueue {
        return GCDQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))
    }
    
    public func dispatch(block: () -> ()) {
        dispatch_async(queue, block)
    }
    
    public func dispatchAndWait(block: () -> ()) {
        dispatch_sync(queue, block)
    }
    
    public func dispatchSerialized(block: () -> ()) {
        dispatch_barrier_async(queue, block)
    }

    public var description: String {
        let labelBytes = UnsafePointer<CChar>(dispatch_queue_get_label(queue))
        let (string, _) = String.fromCStringRepairingIllFormedUTF8(labelBytes)
        return string ?? "nil"
    }
}
