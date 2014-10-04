//
//  Validation.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

struct ValidationRule {
    let isValid: @autoclosure () -> Bool
    let invalid: @autoclosure () -> Error
}

class Validator {
    var rules = [ValidationRule]()
    
    func valid(# when: @autoclosure () -> Bool, otherwise: @autoclosure () -> Error) {
        rules.append(ValidationRule(isValid: when, invalid: otherwise))
    }
    
    func isValid() -> Error? {
        for rule in rules {
            if !rule.isValid() {
                return rule.invalid()
            }
        }
        
        return nil
    }
}
