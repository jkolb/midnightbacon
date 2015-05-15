//
//  SubmitForm.swift
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

import UIKit
import Reddit

enum SubmitFieldID : String {
    case Subreddit = "subreddit"
    case Title = "title"
    case Text = "text"
    case URL = "url"
    case SendReplies = "sendReplies"
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

class SubmitLongTextField : SubmitField {
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

class SubmitForm {
    var kind: SubmitKind
    var orderedFields: [SubmitField] = []
    var fieldIndexByID: [SubmitFieldID:Int] = [:]
    
    init(kind: SubmitKind) {
        self.kind = kind
    }
    
    class func linkForm() -> SubmitForm {
        let form = SubmitForm(kind: .LinkKind)
        form.addField(SubmitTextField(id: .Subreddit))
        form.addField(SubmitTextField(id: .Title))
        form.addField(SubmitURLField(id: .URL))
        form.addField(SubmitBoolField(id: .SendReplies))
        return form
    }
    
    class func textForm() -> SubmitForm {
        let form = SubmitForm(kind: .TextKind)
        form.addField(SubmitTextField(id: .Subreddit))
        form.addField(SubmitTextField(id: .Title))
        form.addField(SubmitLongTextField(id: .Text))
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
        fieldIndexByID[field.id] = orderedFields.count
        orderedFields.append(field)
    }
    
    var count: Int {
        return orderedFields.count
    }
    
    subscript(index: Int) -> SubmitField {
        return orderedFields[index]
    }
    
    subscript(id: SubmitFieldID) -> SubmitField? {
        if let index = indexOfFieldID(id) {
            return orderedFields[index]
        } else {
            return nil
        }
    }

    func indexOfFieldID(id: SubmitFieldID) -> Int? {
        return fieldIndexByID[id]
    }
    
    var subredditField: SubmitTextField {
        return self[.Subreddit] as! SubmitTextField
    }
    
    var titleField: SubmitTextField {
        return self[.Title] as! SubmitTextField
    }
    
    var textField: SubmitLongTextField? {
        return self[.Text] as? SubmitLongTextField
    }
    
    var urlField: SubmitURLField? {
        return self[.URL] as? SubmitURLField
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
