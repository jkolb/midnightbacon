// Copyright (c) 2016 Justin Kolb - http://franticapparatus.net
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

public enum HTTPRequestField : String {
    case Accept = "Accept"
    case AcceptCharset = "Accept-Charset"
    case AcceptEncoding = "Accept-Encoding"
    case AcceptLanguage = "Accept-Language"
    case AcceptDatetime = "Accept-Datetime"
    case Authorization = "Authorization"
    case CacheControl = "Cache-Control"
    case Connection = "Connection"
    case Cookie = "Cookie"
    case ContentLength = "Content-Length"
    case ContentMD5 = "Content-MD5"
    case ContentType = "Content-Type"
    case Date = "Date"
    case Expect = "Expect"
    case From = "From"
    case Host = "Host"
    case IfMatch = "If-Match"
    case IfModifiedSince = "If-Modified-Since"
    case IfNoneMatch = "If-None-Match"
    case IfRange = "If-Range"
    case IfUnmodifiedSince = "If-Unmodified-Since"
    case MaxForwards = "Max-Forwards"
    case Origin = "Origin"
    case Pragma = "Pragma"
    case ProxyAuthorization = "Proxy-Authorization"
    case Range = "Range"
    case Referer = "Referer"
    case TE = "TE"
    case UserAgent = "User-Agent"
    case Upgrade = "Upgrade"
    case Via = "Via"
    case Warning = "Warning"
}
