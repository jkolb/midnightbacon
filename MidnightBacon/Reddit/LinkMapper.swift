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

import ModestProposal
import FranticApparatus

class LinkMapper : ThingMapper {
    init() { }
    
    func map(json: JSON) -> Outcome<Thing, Error> {
        if let url = json["url"].asURL {
            return Outcome(
                Link(
                    id: json["id"].asString ?? "",
                    name: json["name"].asString ?? "",
                    title: json["title"].asUnescapedString ?? "",
                    url: url,
                    thumbnail: json["thumbnail"].thumbnail,
                    created: json["created_utc"].asSecondsSince1970 ?? NSDate(),
                    author: json["author"].asString ?? "",
                    domain: json["domain"].asString ?? "",
                    subreddit: json["subreddit"].asString ?? "",
                    commentCount: json["num_comments"].asInteger ?? 0,
                    permalink: json["permalink"].asString ?? "",
                    over18: json["over_18"].asBoolean ?? false,
                    distinguished: json["over_18"].asString ?? "",
                    stickied: json["stickied"].asBoolean ?? false,
                    visited: json["visited"].asBoolean ?? false,
                    saved: json["saved"].asBoolean ?? false,
                    isSelf: json["is_self"].asBoolean ?? false,
                    likes: json["likes"].asVoteDirection
                )
            )
        } else {
            return Outcome(Error(message: "Skipped link due to invalid URL: " + (json["url"].asString ?? "")))
        }
    }
}
