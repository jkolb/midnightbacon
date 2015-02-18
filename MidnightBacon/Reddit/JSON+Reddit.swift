//
//  JSON+Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

extension JSON {
    var date: NSDate {
        return NSDate(timeIntervalSince1970: number.doubleValue)
    }
    
    var dateOrNil: NSDate? {
        if let number = numberOrNil {
            return date
        } else {
            return nil
        }
    }
    
    var url: NSURL? {
        return string.length == 0 ? nil : NSURL(string: string as! String)
    }
    
    var voteDirection: VoteDirection {
        if let nonNilNumber = numberOrNil {
            if nonNilNumber.boolValue {
                return .Upvote
            } else {
                return .Downvote
            }
        } else {
            return .None
        }
    }
    
    var unescapedString: String {
        let string: String = self.string as! String
        return string.unescapeEntities()
    }
    
    var integer: Int {
        return number.integerValue
    }
    
    var boolean: Bool {
        return number.boolValue
    }
    
    var thumbnail: Thumbnail? {
        if let thumbnail = self.stringOrNil as? String {
            if thumbnail == "" {
                return nil
            } else if let builtInType = BuiltInType(rawValue: thumbnail) {
                return Thumbnail.BuiltIn(builtInType)
            } else if let thumbnailURL = NSURL(string: thumbnail) {
                return Thumbnail.URL(thumbnailURL)
            } else {
                return Thumbnail.BuiltIn(.Default)
            }
        } else {
            return nil
        }
    }
}

func redditJSONValidator(response: NSURLResponse) -> Error? {
    if let error = Validator.defaultJSONResponseValidator(response).validate() {
        return NSErrorWrapperError(cause: error)
    } else {
        return nil
    }
}

func redditJSONParser(JSONData: NSData) -> Outcome<JSON, Error> {
    switch defaultJSONTransformer(JSONData) {
    case .Success(let JSONProducer):
        let JSON = JSONProducer.unwrap
        if isRedditErrorJSON(JSON) {
            return .Failure(Value(redditErrorMapper(JSON)))
        } else {
            return .Success(Value(JSON))
        }
    case .Failure(let reasonProducer):
        return .Failure(Value(NSErrorWrapperError(cause: reasonProducer.unwrap)))
    }
}

func redditJSONMapper<T>(response: URLResponse, mapper: (JSON) -> Outcome<T, Error>) -> Outcome<T, Error> {
    if let error = redditJSONValidator(response.metadata) {
        return .Failure(Value(error))
    } else {
        switch redditJSONParser(response.data) {
        case .Success(let JSONProducer):
            return mapper(JSONProducer.unwrap)
        case .Failure(let reasonProducer):
            return .Failure(Value(reasonProducer.unwrap))
        }
    }
}

func redditImageValidator(response: NSURLResponse) -> Error? {
    if let error = Validator.defaultImageResponseValidator(response).validate() {
        return NSErrorWrapperError(cause: error)
    } else {
        return nil
    }
}

func redditImageParser(response: URLResponse) -> Outcome<UIImage, Error> {
    if let error = redditImageValidator(response.metadata) {
        return .Failure(Value(error))
    } else {
        switch defaultImageTransformer(response.data) {
        case .Success(let imageProducer):
            return .Success(Value(imageProducer.unwrap))
        case .Failure(let reasonProducer):
            return .Failure(Value(NSErrorWrapperError(cause: reasonProducer.unwrap)))
        }
    }
}
