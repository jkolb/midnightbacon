//
//  Account.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

// Kind: t2
class Account : Equatable, Hashable {
    let id: String
    let name: String
    let modhash: String?
    let linkKarma: Int
    let commentKarma: Int
    let created: NSDate
    let createdUTC: NSDate
    let hasMail: Bool
    let hasModMail: Bool
    let hasVerifiedEmail: Bool
    let hideFromRobots: Bool
    let isFriend: Bool
    let isMod: Bool
    let over18: Bool
    let isGold: Bool
    let goldCredits: Int
    let goldExpiration: NSDate?
    
    init(
        id: String,
        name: String,
        modhash: String?,
        linkKarma: Int,
        commentKarma: Int,
        created: NSDate,
        createdUTC: NSDate,
        hasMail: Bool,
        hasModMail: Bool,
        hasVerifiedEmail: Bool,
        hideFromRobots: Bool,
        isFriend: Bool,
        isMod: Bool,
        over18: Bool,
        isGold: Bool,
        goldCredits: Int,
        goldExpiration: NSDate?
        )
    {
        self.id = id
        self.name = name
        self.modhash = modhash
        self.linkKarma = linkKarma
        self.commentKarma = commentKarma
        self.created = created
        self.createdUTC = createdUTC
        self.hasMail = hasMail
        self.hasModMail = hasModMail
        self.hasVerifiedEmail = hasVerifiedEmail
        self.hideFromRobots = hideFromRobots
        self.isFriend = isFriend
        self.isMod = isMod
        self.over18 = over18
        self.isGold = isGold
        self.goldCredits = goldCredits
        self.goldExpiration = goldExpiration
    }
    
    var hashValue: Int {
        return name.hash
    }
}

func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.name == rhs.name
}
