//
//  AccountMapper.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import ModestProposal
import FranticApparatus

class AccountMapper {
    func fromAPI(json: JSON) -> ParseResult<Account> {
        let kind = json["kind"].string
        
        if kind != "t2" {
            return .Failure(Error(message: "Unknown kind: \(kind)"))
        }
        
        let data = json["data"]
        
        if !data.isObject {
            return .Failure(Error(message: ""))
        }
        return fromJSON(data)
    }
    
    func fromJSON(json: JSON) -> ParseResult<Account> {
        return .Success(
            Account(
                id: "",
                name: "",
                modhash: nil,
                linkKarma: 0,
                commentKarma: 0,
                created: NSDate(),
                createdUTC: NSDate(),
                hasMail: false,
                hasModMail: false,
                hasVerifiedEmail: false,
                hideFromRobots: false,
                isFriend: false,
                isMod: false,
                over18: false,
                isGold: false,
                goldCredits: 0,
                goldExpiration: nil
            )
        )
    }
}
