//
//  SubmitForm.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 4/23/15.
//  Copyright (c) 2015 Justin Kolb. All rights reserved.
//

import UIKit

enum SubmitFieldID : String {
    case Subreddit = "subreddit"
    case Title = "title"
    case Text = "text"
    case URL = "url"
    case SendReplies = "sendReplies"
}

enum SubmitKind : String {
    case LinkKind = "link"
    case SelfKind = "self"
    
    static func allKinds() -> [SubmitKind] {
        return [.LinkKind, .SelfKind]
    }
    
    var hasURL: Bool {
        switch self {
        case .LinkKind:
            return true
        case .SelfKind:
            return false
        }
    }
    
    var hasText: Bool {
        switch self {
        case .LinkKind:
            return false
        case .SelfKind:
            return true
        }
    }
}

class SubmitField : Equatable {
    let id: SubmitFieldID
    
    init(id: SubmitFieldID) {
        self.id = id
    }
    
    func isValid() -> Bool {
        return true
    }
}

func ==(lhs: SubmitField, rhs: SubmitField) -> Bool {
    return lhs.id == rhs.id
}

class SubmitBoolField : SubmitField {
    var value: Bool?
}

class SubmitKindField : SubmitField {
    var value: SubmitKind?
}

class SubmitTextField : SubmitField {
    var value: String?
    
    override func isValid() -> Bool {
        if let stringValue = value {
            return !stringValue.isEmpty
        } else {
            return false
        }
    }
}

class SubmitURLField : SubmitField {
    var value: NSURL?
    
    var stringValue: String? {
        get {
            return value?.absoluteString
        }
        set {
            let urlString = newValue ?? ""
            
            if urlString.isEmpty {
                value = nil
            } else {
                value = NSURL(string: urlString)
            }
        }
    }
    
    override func isValid() -> Bool {
        if let url = value {
            let scheme = url.scheme ?? ""
            let host = url.host ?? ""
            
            return (scheme == "http" || scheme == "https") && !host.isEmpty
        } else {
            return false
        }
    }
}

class SubmitCaptchaField : SubmitField {
    var captcha: Captcha?
}

class SubmitForm {
    var orderedFields: [SubmitField] = []
    var fieldByID: [SubmitFieldID:SubmitField] = [:]
    
    class func linkForm() -> SubmitForm {
        let form = SubmitForm()
        form.addField(SubmitTextField(id: .Subreddit))
        form.addField(SubmitTextField(id: .Title))
        form.addField(SubmitURLField(id: .URL))
        form.addField(SubmitBoolField(id: .SendReplies))
        return form
    }
    
    class func textForm() -> SubmitForm {
        let form = SubmitForm()
        form.addField(SubmitTextField(id: .Subreddit))
        form.addField(SubmitTextField(id: .Title))
        form.addField(SubmitTextField(id: .Text))
        form.addField(SubmitBoolField(id: .SendReplies))
        return form
    }
    
    func isValid() -> Bool {
        var valid = true
        
        for field in orderedFields {
            valid = valid && field.isValid()
        }
        
        return valid
    }
    
    func addField(field: SubmitField) {
        orderedFields.append(field)
        fieldByID[field.id] = field
    }
    
    func indexOfField(field: SubmitField) -> Int? {
        return find(orderedFields, field)
    }
    
    var count: Int {
        return orderedFields.count
    }
    
    subscript(index: Int) -> SubmitField {
        return orderedFields[index]
    }
    
    subscript(id: SubmitFieldID) -> SubmitField {
        return fieldByID[id]!
    }
    
    var subredditField: SubmitTextField {
        return self[.Subreddit] as! SubmitTextField
    }
    
    var titleField: SubmitTextField {
        return self[.Title] as! SubmitTextField
    }
    
    var textField: SubmitTextField {
        return self[.Text] as! SubmitTextField
    }
    
    var urlField: SubmitURLField {
        return self[.URL] as! SubmitURLField
    }
    
    var sendRepliesField: SubmitBoolField {
        return self[.SendReplies] as! SubmitBoolField
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