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

public class UnauthorizedError : Error {}

extension Double : JSONConvertible {
    public var json: JSON {
        return JSON(value: .Number(NSNumber(double: self)))
    }
}

extension JSON {
    var asVoteDirection: VoteDirection {
        if let number = asNumber {
            if number.boolValue {
                return .Upvote
            } else {
                return .Downvote
            }
        } else {
            return .None
        }
    }
    
    var thumbnail: Thumbnail? {
        if let thumbnail = self.asString {
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

func redditJSONResponseValidator(response: NSURLResponse) -> Validator {
    let builder = ValidatorBuilder()
    builder.valid(when: response.isHTTP, otherwise: NSError.notAnHTTPResponseError())
    builder.valid(when: response.asHTTP.isSuccessful || response.asHTTP.isStatus(.Unauthorized), otherwise: NSError.unexpectedStatusCodeError(response.asHTTP.statusCode))
    builder.valid(when: response.asHTTP.isJSON, otherwise: NSError.unexpectedContentTypeError(response.asHTTP.MIMEType))
    return builder.build()
}

func redditJSONValidator(response: NSURLResponse) -> Error? {
    if let error = redditJSONResponseValidator(response).validate() {
        return NSErrorWrapperError(cause: error)
    } else if response.asHTTP.isStatus(.Unauthorized) {
        return UnauthorizedError()
    } else {
        return nil
    }
}

public func redditJSONParser(JSONData: NSData) -> Outcome<JSON, Error> {
    switch defaultJSONTransformer(JSONData) {
    case .Success(let JSONProducer):
        let JSON = JSONProducer.unwrap
        if isRedditErrorJSON(JSON) {
            return Outcome(redditErrorMapper(JSON))
        } else {
            return Outcome(JSON)
        }
    case .Failure(let reasonProducer):
        return Outcome(NSErrorWrapperError(cause: reasonProducer.unwrap))
    }
}

func redditJSONMapper<T>(response: URLResponse, mapper: (JSON) -> Outcome<T, Error>) -> Outcome<T, Error> {
    if let error = redditJSONValidator(response.metadata) {
        return Outcome(error)
    } else {
        switch redditJSONParser(response.data) {
        case .Success(let JSONProducer):
            return mapper(JSONProducer.unwrap)
        case .Failure(let reasonProducer):
            return Outcome(reasonProducer.unwrap)
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

public func redditImageParser(response: URLResponse) -> Outcome<UIImage, Error> {
    if let error = redditImageValidator(response.metadata) {
        return Outcome(error)
    } else {
        switch defaultImageTransformer(response.data) {
        case .Success(let imageProducer):
            return Outcome(imageProducer.unwrap)
        case .Failure(let reasonProducer):
            return Outcome(NSErrorWrapperError(cause: reasonProducer.unwrap))
        }
    }
}

extension String {
    init?(_ value: Int?) {
        if let nonNilValue = value {
            self.init(nonNilValue)
        } else {
            return nil
        }
    }
    
    init?(_ value: Bool?) {
        if let nonNilValue = value {
            if nonNilValue {
                self.init("true")
            } else {
                self.init("false")
            }
        } else {
            return nil
        }
    }
}
