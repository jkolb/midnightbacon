//
//  Account.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/11/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

public class Account : Thing {
    public let modhash: String
    public let linkKarma: Int
    public let commentKarma: Int
    public let created: NSDate
    public let createdUTC: NSDate
    public let hasMail: Bool
    public let hasModMail: Bool
    public let hasVerifiedEmail: Bool
    public let hideFromRobots: Bool
    public let isFriend: Bool
    public let isMod: Bool
    public let over18: Bool
    public let isGold: Bool
    public let goldCreddits: Int
    public let goldExpiration: NSDate?
    
    public init(
        id: String,
        name: String,
        modhash: String,
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
        goldCreddits: Int,
        goldExpiration: NSDate?
        )
    {
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
        self.goldCreddits = goldCreddits
        self.goldExpiration = goldExpiration
        super.init(kind: .Account, id: id, name: name)
    }
    
    public override var debugDescription: String {
        return "\(super.debugDescription) \(name)"
    }
}
