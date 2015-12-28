//
//  JSON+Reddit.swift
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
import ModestProposal
import FranticApparatus
import Jasoom

public enum RedditAPIError : ErrorType {
    case Unauthorized
    case InvalidImage
}

extension JSON {
    var asVoteDirection: VoteDirection {
        if let number = numberValue {
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
        if let thumbnail = stringValue as? Swift.String {
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

public func redditJSONResponseValidator(response: NSURLResponse) throws {
    try validate(when: response.isHTTP, otherwise: HTTPError.UnexpectedResponse(response))
    try validate(when: response.HTTP.isSuccessful || response.HTTP.isStatus(.Unauthorized), otherwise: HTTPError.UnexpectedStatusCode(response.HTTP.statusCode))
    try validate(when: response.HTTP.isJSON, otherwise: HTTPError.UnexpectedContentType(response.HTTP.MIMEType))
}

public func redditJSONValidator(response: NSURLResponse) throws {
    try redditJSONResponseValidator(response)
    
    if response.HTTP.isStatus(.Unauthorized) {
        throw RedditAPIError.Unauthorized
    }
}

public func redditJSONParser(JSONData: NSData) throws -> JSON {
    let object = try JSON.parseData(JSONData)
    if isRedditErrorJSON(object) {
        throw redditErrorMapper(object)
    }
    return object
}

public func redditJSONMapper<T>(response: URLResponse, @noescape mapper: (JSON) throws -> T) throws -> T {
    try redditJSONValidator(response.metadata)
    let object = try redditJSONParser(response.data)
    return try mapper(object)
}

public func redditImageValidator(response: NSURLResponse) throws {
    try response.validateIsSuccessfulImage()
}

public func redditImageParser(response: URLResponse) throws -> UIImage {
    try redditImageValidator(response.metadata)
    guard let image = UIImage(data: response.data) else {
        throw RedditAPIError.InvalidImage
    }
    return image
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
