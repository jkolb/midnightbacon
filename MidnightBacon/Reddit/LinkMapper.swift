//
//  LinkMapper.swift
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

import Jasoom

class LinkMapper : ThingMapper {
    init() { }
    
    func map(json: JSON) throws -> Thing {
        if let url = json["url"].URLValue {
            return Link(
                id: json["id"].textValue ?? "",
                name: json["name"].textValue ?? "",
                title: json["title"].unescapedTextValue ?? "",
                url: url,
                thumbnail: json["thumbnail"].thumbnail,
                created: json["created_utc"].dateValue ?? NSDate(),
                author: json["author"].textValue ?? "",
                domain: json["domain"].textValue ?? "",
                subreddit: json["subreddit"].textValue ?? "",
                commentCount: json["num_comments"].intValue ?? 0,
                permalink: json["permalink"].textValue ?? "",
                over18: json["over_18"].boolValue ?? false,
                distinguished: json["over_18"].textValue ?? "",
                stickied: json["stickied"].boolValue ?? false,
                visited: json["visited"].boolValue ?? false,
                saved: json["saved"].boolValue ?? false,
                isSelf: json["is_self"].boolValue ?? false,
                likes: json["likes"].asVoteDirection
            )
        } else {
            throw ThingError.InvalidLinkURL(json["url"].textValue ?? "")
        }
    }
}
