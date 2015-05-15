//
//  Account.swift
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
