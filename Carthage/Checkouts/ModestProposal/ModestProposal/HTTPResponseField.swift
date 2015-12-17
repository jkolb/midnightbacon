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

public enum HTTPResponseField : String {
    case AccessControlAllowOrigin = "Access-Control-Allow-Origin"
    case AcceptRanges = "Accept-Ranges"
    case Age = "Age"
    case Allow = "Allow"
    case CacheControl = "Cache-Control"
    case Connection = "Connection"
    case ContentEncoding = "Content-Encoding"
    case ContentLanguage = "Content-Language"
    case ContentLength = "Content-Length"
    case ContentLocation = "Content-Location"
    case ContentMD5 = "Content-MD5"
    case ContentDisposition = "Content-Disposition"
    case ContentRange = "Content-Range"
    case ContentType = "Content-Type"
    case Date = "Date"
    case ETag = "ETag"
    case Expires = "Expires"
    case LastModified = "Last-Modified"
    case Link = "Link"
    case Pragma = "Pragma"
    case ProxyAuthenticate = "Proxy-Authenticate"
    case Refresh = "Refresh"
    case RetryAfter = "Retry-After"
    case Server = "Server"
    case SetCookie = "Set-Cookie"
    case Status = "Status"
    case StrictTransportSecurity = "Strict-Transport-Security"
    case Trailer = "Trailer"
    case TransferEncoding = "Transfer-Encoding"
    case Upgrade = "Upgrade"
    case Vary = "Vary"
    case Via = "Via"
    case Warning = "Warning"
    case WWWAuthenticate = "WWW-Authenticate"
}
