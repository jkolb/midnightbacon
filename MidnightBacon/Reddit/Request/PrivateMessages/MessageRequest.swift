//
//  MessageRequest.swift
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

import Common
import ModestProposal
import FranticApparatus

public enum MessageWhere : String {
    case Inbox = "inbox"
    case Unread = "unread"
    case Messages = "messages" // Shows up in web not in API docs
    case Comments = "comments" // Shows up in web not in API docs
    case SelfReply = "selfreply" // Shows up in web not in API docs
    case mentions = "mentions" // Shows up in web not in API docs
    case Sent = "sent"
    case Moderator = "moderator" // Shows up in web not in API docs
    case ModeratorUnread = "moderator/unread" // Shows up in web not in API docs
}

class MessageRequest : APIRequest {
    let mapperFactory: RedditFactory
    let prototype: NSURLRequest
    let messageWhere: MessageWhere
    let mark: Bool?
    let mid: String?
    let after: String?
    let before: String?
    let count: Int? // Default 0
    let limit: Int? // Default 25, Maximum 100
    let show: String? // all
    let expandSubreddits: String?
    
    init(mapperFactory: RedditFactory, prototype: NSURLRequest, messageWhere: MessageWhere, mark: Bool?, mid: String?, after: String?, before: String?, count: Int?, limit: Int?, show: String?, expandSubreddits: String?) {
        self.mapperFactory = mapperFactory
        self.prototype = prototype
        self.messageWhere = messageWhere
        self.mark = mark
        self.mid = mid
        self.after = after
        self.before = before
        self.count = count
        self.limit = limit
        self.show = show
        self.expandSubreddits = expandSubreddits
    }
    
    typealias ResponseType = Listing
    
    func parse(response: URLResponse) -> Outcome<Listing, Error> {
        let mapperFactory = self.mapperFactory
        return redditJSONMapper(response) { (json) -> Outcome<Listing, Error> in
            return mapperFactory.listingMapper().map(json)
        }
    }
    
    func build() -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 8)
        parameters["mark"] = String(mark)
        parameters["mid"] = mid
        parameters["after"] = after
        parameters["before"] = before
        parameters["count"] = String(count)
        parameters["limit"] = String(limit)
        parameters["show"] = show
        parameters["sr_detail"] = expandSubreddits
        return prototype.GET("/message/\(messageWhere.rawValue).json", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return .PrivateMessages
    }
}
