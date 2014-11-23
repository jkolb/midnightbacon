//
//  TargetAction.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/21/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import ObjectiveC

class TargetAction {
    let block: (() -> ())
    
    init(block: (() -> ())) {
        self.block = block
    }
    
    var selector: Selector {
        return Selector("execute")
    }
    
    @objc func execute() {
        block()
    }
}

extension UIBarButtonItem {
    /*
    case Done
    case Cancel
    case Edit
    case Save
    case Add
    case FlexibleSpace
    case FixedSpace
    case Compose
    case Reply
    case Action
    case Organize
    case Bookmarks
    case Search
    case Refresh
    case Stop
    case Camera
    case Trash
    case Play
    case Pause
    case Rewind
    case FastForward
    
    case Undo
    case Redo
    
    case PageCurl
    */
    class func done(action: TargetAction) -> UIBarButtonItem {
        return UIBarButtonItem(systemItem: .Done, action: action)
    }
    
    convenience init(systemItem: UIBarButtonSystemItem, action: TargetAction) {
        self.init(barButtonSystemItem: systemItem, target: action, action: action.selector)
    }
    
    convenience init(title: String, style: UIBarButtonItemStyle, action: TargetAction) {
        self.init(title: title, style: style, target: action, action: action.selector)
    }
}

func action<T: AnyObject>(context: T, block: (T) -> ()) -> TargetAction {
    return TargetAction { [unowned context] in
        block(context)
    }
}
