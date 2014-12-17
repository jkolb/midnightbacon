//
//  OAuthScope.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/14/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

enum OAuthScope : String {
    case Account = "account"
    case Creddits = "creddits"
    case Edit = "edit"
    case Flair = "flair"
    case History = "history"
    case Identity = "identity"
    case LiveManage = "livemanage"
    case ModConfig = "modconfig"
    case ModFlair = "modflair"
    case ModLog = "modlog"
    case ModPosts = "modposts"
    case ModWiki = "modwiki"
    case MySubreddits = "mysubreddits"
    case PrivateMessages = "privatemessages"
    case Read = "read"
    case Report = "report"
    case Save = "save"
    case Submit = "submit"
    case Subscribte = "subscribe"
    case Vote = "vote"
    case WikiEdit = "wikiedit"
    case WikiRead = "wikiread"
}

func rawValues<T : RawRepresentable>(rawRepresentables: [T]) -> [T.RawValue] {
    var rawValues = Array<T.RawValue>()

    for rawRepresentable in rawRepresentables {
        rawValues.append(rawRepresentable.rawValue)
    }
    
    return rawValues
}
