//
//  String+Entities.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/15/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

extension String {
    func unescapeEntities(entities: [String:String] = XMLSpecialC0ControlAndBasicLatinEntities, longestName: Int = 8) -> String {
        enum State {
            case Looking
            case Started
            case Extract
        }
        let ampersand = UnicodeScalar(0x0026)
        let semicolon = UnicodeScalar(0x003B)
        let scalars = self.unicodeScalars
        var state = State.Looking
        var unescaped = String()
        unescaped.reserveCapacity(countElements(scalars))
        var name = String()
        name.reserveCapacity(longestName)
        
        for scalar in scalars {
            switch state {
            case .Looking:
                if scalar == ampersand {
                    state = .Started
                } else {
                    unescaped.append(scalar)
                }
            case .Started:
                if scalar == ampersand {
                    unescaped.append(ampersand)
                } else if scalar == semicolon {
                    unescaped.append(ampersand)
                    unescaped.append(semicolon)
                    state = .Looking
                } else {
                    name.append(scalar)
                    state = .Extract
                }
            case .Extract:
                if scalar == ampersand {
                    unescaped.append(ampersand)
                    unescaped.extend(name)
                    name.removeAll(keepCapacity: true)
                    state = .Started
                } else if scalar == semicolon {
                    if let entity = entities[name] {
                        unescaped.extend(entity)
                    } else {
                        unescaped.append(ampersand)
                        unescaped.extend(name)
                        unescaped.append(semicolon)
                    }
                    name.removeAll(keepCapacity: true)
                    state = .Looking
                } else if countElements(name.unicodeScalars) >= longestName {
                    unescaped.append(ampersand)
                    unescaped.extend(name)
                    unescaped.append(scalar)
                    name.removeAll(keepCapacity: true)
                    state = .Looking
                } else {
                    name.append(scalar)
                }
            }
        }
        
        switch state {
        case .Looking:
            break
        case .Started:
            unescaped.append(ampersand)
        case .Extract:
            unescaped.append(ampersand)
            unescaped.extend(name)
        }
        
        return unescaped
    }
    
    static var XMLSpecialC0ControlAndBasicLatinEntities: [String:String] {
        // http://www.w3.org/TR/xhtml1/dtds.html#h-A2
        // A.2. Entity Sets
        // A.2.2. Special characters
        // C0 Controls and Basic Latin
        return [
            "quot": "\"",
            "amp": "&",
            "lt": "<",
            "gt": ">",
            "apos":"'",
        ]
    }
}
