//
//  CommentsRequest.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 3/20/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

enum CommentsSort : String {
    case Confidence = "confience"
    case Top = "top"
    case New = "new"
    case Hot = "hot"
    case Controversial = "controversial"
    case Old = "old"
    case Random = "random"
    case QA = "qa"
}

/*
Get the comment tree for a given Link article.
If supplied, comment is the ID36 of a comment in the comment tree for article. This comment will be the (highlighted) focal point of the returned view and context will be the number of parents shown.
depth is the maximum depth of subtrees in the thread.
limit is the maximum number of comments to return.
See also: /api/morechildren and /api/comment.
*/
class CommentsRequest : APIRequest {
    let article: String // ID36 of a link
    let comment: String? // (optional) ID36 of a comment
    let context: Int? // an integer between 0 and 8
    let depth: Int? // (optional) an integer
    let limit: Int? // (optional) an integer
    let showedits: Bool?
    let showmore: Bool?
    let sort: CommentsSort? // One of (confidence, top, new, hot, controversial, old, random, qa)
    
    convenience init(article: Link) {
        self.init(article: article.id, comment: nil, context: nil, depth: nil, limit: nil, showedits: nil, showmore: nil, sort: nil)
    }
    
    init(article: String, comment: String?, context: Int?, depth: Int?, limit: Int?, showedits: Bool?, showmore: Bool?, sort: CommentsSort?) {
        assert(count(article) > 0, "Invalid article")
        self.article = article
        self.comment = comment
        self.context = context
        self.depth = depth
        self.limit = limit
        self.showedits = showedits
        self.showmore = showmore
        self.sort = sort
    }
    
    typealias ResponseType = (Link, Listing)
    
    func parse(response: URLResponse, mapperFactory: RedditFactory) -> Outcome<(Link, Listing), Error> {
        return redditJSONMapper(response) { (json) -> Outcome<(Link, Listing), Error> in
            if !json.isArray {
                return Outcome(UnexpectedJSONError())
            }
            
            if json.count != 2 {
                return Outcome(UnexpectedJSONError())
            }
            
            let linkOutcome = mapperFactory.linkMapper().map(json[0])
            let listingOutcome = mapperFactory.listingMapper().map(json[1])

            switch (linkOutcome, listingOutcome) {
            case (.Success(let linkResult), .Success(let listingResult)):
                return Outcome((linkResult.unwrap as! Link, listingResult.unwrap))
            case (.Success(let linkResult), .Failure(let listingReason)):
                return Outcome(listingReason.unwrap)
            case (.Failure(let linkReason), .Success(let listingResult)):
                return Outcome(linkReason.unwrap)
            case (.Failure(let linkReason), .Failure(let listingReason)):
                return Outcome(linkReason.unwrap)
            }
        }
    }
    
    func build(prototype: NSURLRequest) -> NSMutableURLRequest {
        var parameters = [String:String](minimumCapacity: 7)
        parameters["comment"] = comment
        parameters["context"] = String(context)
        parameters["depth"] = String(depth)
        parameters["limit"] = String(limit)
        parameters["showedits"] = String(showedits)
        parameters["showmore"] = String(showmore)
        parameters["sort"] = sort?.rawValue
        return prototype.GET("/comments/\(article).json", parameters: parameters)
    }
    
    var requiresModhash : Bool {
        return false
    }
    
    var scope : OAuthScope? {
        return .Read
    }
}
