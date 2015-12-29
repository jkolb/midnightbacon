//
//  CommentMapper.swift
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

/*
{
    "data": {
        "approved_by": null,
        "archived": false,
        "author": "StacySwanson",
        "author_flair_css_class": null,
        "author_flair_text": null,
        "banned_by": null,
        "body": "no",
        "body_html": "&lt;div class=\"md\"&gt;&lt;p&gt;no&lt;/p&gt;\n&lt;/div&gt;",
        "controversiality": 0,
        "created": 1426841872.0,
        "created_utc": 1426813072.0,
        "distinguished": null,
        "downs": 0,
        "edited": false,
        "gilded": 0,
        "id": "cpkivdp",
        "likes": null,
        "link_id": "t3_2zmdjk",
        "mod_reports": [],
        "name": "t1_cpkivdp",
        "num_reports": null,
        "parent_id": "t1_cpki27u",
        "replies": "",
        "report_reasons": null,
        "saved": false,
        "score": 1,
        "score_hidden": false,
        "subreddit": "funny",
        "subreddit_id": "t5_2qh33",
        "ups": 1,
        "user_reports": []
    },
    "kind": "t1"
}
 */
class CommentMapper : ThingMapper {
    var listingMapper: ListingMapper!
    
    func map(json: JSON) throws -> Thing {
        var replies: Listing?
        
        do {
            replies = try listingMapper.map(json["replies"])
        }
        catch {
            print(error)
            replies = Listing.empty()
        }
        
        return Comment(
            id: json["id"].textValue ?? "",
            name: json["name"].textValue ?? "",
            parentID: json["parentID"].textValue ?? "",
            author: json["author"].textValue ?? "",
            body: json["body"].unescapedTextValue ?? "",
            bodyHTML: json["body_html"].unescapedTextValue ?? "",
            createdUTC: json["created_utc"].dateValue ?? NSDate(),
            replies: replies
        )

    }
}
