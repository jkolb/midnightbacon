//
//  NSHTTPURLResponse+Validation.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus

extension NSHTTPURLResponse {
    func validate(statusCodes: [Int] = [200], contentTypes: [String] = []) -> Error? {
        return validator().validate()
    }
    
    func validator(statusCodes: [Int] = [200], contentTypes: [String] = []) -> Validator {
        let validator = Validator()
        
        if countElements(statusCodes) > 0 {
            validator.valid(when: contains(statusCodes, statusCode), otherwise: UnexpectedHTTPStatusCodeError(statusCode))
        }
        
        if countElements(contentTypes) > 0 {
            validator.valid(when: MIMEType != nil, otherwise: UnknownHTTPContentTypeError())
            validator.valid(when: contains(contentTypes, MIMEType!), otherwise: UnexpectedHTTPContentTypeError(MIMEType!))
        }
        
        return validator
    }
    
    func JSONValidator(statusCodes: [Int] = [200]) -> Validator {
        return validator(statusCodes: statusCodes, contentTypes: [MediaType.ApplicationJSON.rawValue])
    }
    
    func imageValidator(statusCodes: [Int] = [200]) -> Validator {
        return validator(statusCodes: statusCodes, contentTypes: [MediaType.ImageJPEG.rawValue, MediaType.ImagePNG.rawValue, MediaType.ImageGIF.rawValue])
    }
}

class UnexpectedHTTPStatusCodeError : Error {
    let statusCode: Int
    
    init(_ statusCode: Int) {
        self.statusCode = statusCode
        super.init(message: "Status Code = \(statusCode)")
    }
}

class UnknownHTTPContentTypeError : Error { }

class UnexpectedHTTPContentTypeError : Error {
    let contentType: String
    
    init(_ contentType: String) {
        self.contentType = contentType
        super.init(message: "Content Type = " + contentType)
    }
}
