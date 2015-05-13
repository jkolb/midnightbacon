//
//  MessageRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 5/12/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
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
