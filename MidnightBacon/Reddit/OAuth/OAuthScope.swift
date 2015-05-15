//
//  OAuthScope.swift
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

public enum OAuthScope : String {
    case Account = "account"
    case Creddits = "creddits"
    case Edit = "edit"
    case Flair = "flair"
    case History = "history"
    case Identity = "identity"
    case LiveManage = "livemanage"
    case ModConfig = "modconfig"
    case ModFlair = "modflair"
    case ModLog = "modlog"
    case ModPosts = "modposts"
    case ModWiki = "modwiki"
    case MySubreddits = "mysubreddits"
    case PrivateMessages = "privatemessages"
    case Read = "read"
    case Report = "report"
    case Save = "save"
    case Submit = "submit"
    case Subscribe = "subscribe"
    case Vote = "vote"
    case WikiEdit = "wikiedit"
    case WikiRead = "wikiread"
}
