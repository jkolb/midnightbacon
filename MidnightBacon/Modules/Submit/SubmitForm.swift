//
//  SubmitForm.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import Foundation

protocol SubmitField {
    typealias ValueType
    
    var type: SubmitFieldType { get }
    var value: ValueType { get set }
}

enum SubmitFieldType : String {
    case SubmitKind = "submitKind"
    case Subreddit = "subreddit"
    case Title = "title"
    case Text = "text"
    case URL = "url"
    case SendReplies = "sendReplies"
    case Captcha = "captcha"
}

enum SubmitKindValue : String {
    case LinkKind = "link"
    case SelfKind = "self"
    
    static func allKinds() -> [SubmitKindValue] {
        return [.LinkKind, .SelfKind]
    }
}
/*
kind            one of (link, self)
two buttons next to each other that toggle the other, or a UISegmented control?

sr              name of a subreddit (picker for subscribed?)
text field

title           title of the submission. up to 300 characters long
text view or text field

text            raw markdown text
text view

OR
url             a valid URL
text field

sendreplies     boolean value
switch

captcha         the user's response to the CAPTCHA challenge
image + text field

??? acount chooser? have to recheck for if need captcha


api_type        the string json
extension       extension used for redirects
resubmit        boolean value
iden            the identifier of the CAPTCHA challenge
then            one of (tb, comments)
*/