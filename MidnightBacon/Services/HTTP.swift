//
//  HTTP.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import FranticApparatus
import ModestProposal

class HTTP {
    enum Method : String {
        case CONNECT = "CONNECT"
        case DELETE = "DELETE"
        case GET = "GET"
        case HEAD = "HEAD"
        case OPTIONS = "OPTIONS"
        case PATCH = "PATCH"
        case POST = "POST"
        case PUT = "PUT"
        case TRACE = "TRACE"
    }
    
    enum RequestField : String {
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

    enum ResponseField : String {
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
    
    enum StatusCode : Int {
        case Continue = 100
        case SwitchingProtocols = 101
        case Processing = 102
        
        case OK = 200
        case Created = 201
        case Accepted = 202
        case NonAuthoritativeInformation = 203
        case NoContent = 204
        case ResetContent = 205
        case ParitalContent = 206
        case MultiStatus = 207
        case AlreadyReported = 208
        case IMUsed = 226
        
        case MultipleChoices = 300
        case MovedPermanently = 301
        case Found = 302
        case SeeOther = 303
        case NotModified = 304
        case UseProxy = 305
        case SwitchProxy = 306
        case TemporaryRedirect = 307
        case PermanentRedirect = 308
        
        case BadRequest = 400
        case Unauthorized = 401
        case PaymentRequired = 402
        case Forbidden = 403
        case NotFound = 404
        case MethodNotAllowed = 405
        case NotAcceptable = 406
        case ProxyAuthenticationRequired = 407
        case RequestTimeout = 408
        case Conflict = 409
        case Gone = 410
        case LengthRequired = 411
        case PreconditionFailed = 412
        case RequestEntityTooLarge = 413
        case RequestURITooLong = 414
        case UnsupportedMediaType = 415
        case RequestedRangeNotSatisfiable = 416
        case ExpectationFailed = 417
        case ImATeapot = 418
        case AuthenticationTimeout = 419
        case EnhanceYourCalm = 420
        case UnprocessableEntity = 422
        case Locked = 423
        case FailedDependency = 424
        case UpgradeRequired = 426
        case PreconditionRequired = 428
        case TooManyRequests = 429
        case RequestHeaderFieldsTooLarge = 431
        case LoginTimeout = 440
        case NoResponse = 444
        case RetryWith = 449
        case BlockedByWindowsParentalControls = 450
        case UnavailableForLegalReasons = 451
        case RequestHeaderTooLarge = 494
        case CertError = 495
        case NoCert = 496
        case HTTPToHTTPS = 497
        case TokenExpiredInvalid = 498
        case ClientClosedRequest = 499
        
        case InternalServerError = 500
        case NotImplemented = 501
        case BadGateway = 502
        case ServiceUnavailable = 503
        case GatewayTimeout = 504
        case HTTPVersionNotSupported = 505
        case VariantAlsoNegotiates = 506
        case InsufficientStorage = 507
        case LoopDetected = 508
        case BandwidthLimitExceeded = 509
        case NotExtended = 510
        case NetworkAuthenticationRequired = 511
        case OriginError = 520
        case WebServerIsDown = 521
        case ConnectionTimedOut = 522
        case ProxyDeclinedRequest = 523
        case ATimeoutOcurred = 524
        case NetworkReadTimeoutError = 598
        case NetworkConnectTimeoutError = 599
    }
    
    var host: String = ""
    var secure: Bool = false
    var port: UInt = 0
    let factory: URLPromiseFactory
    var userAgent: String = ""
    var defaultHeaders: [String:String] = [:]
    var parseQueue: DispatchQueue = GCDQueue.globalPriorityDefault()
    
    init(factory: URLPromiseFactory = URLSessionPromiseFactory()) {
        self.factory = factory
    }
    
    func parseImage(data: NSData) -> ParseResult<UIImage> {
        if let image = UIImage(data: data) {
            return .Success(image)
        } else {
            return .Failure(UnexpectedImageFormatError())
        }
    }

    func imageValidator(response: NSHTTPURLResponse) -> Validator {
        return response.imageValidator()
    }
    
    func requestImage(url: NSURL) -> Promise<UIImage> {
        return requestImage(NSURLRequest(URL: url))
    }
    
    func requestImage(request: NSURLRequest) -> Promise<UIImage> {
        return requestContent(request, validator: imageValidator, parser: parseImage)
    }
    
    func parseJSON(data: NSData) -> ParseResult<JSON> {
        var error: NSError?
        
        if let json = JSON.parse(data, options: NSJSONReadingOptions(0), error: &error) {
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            return .Success(json)
        } else {
            return .Failure(NSErrorWrapperError(cause: error!))
        }
    }

    func JSONValidator(response: NSHTTPURLResponse) -> Validator {
        return response.JSONValidator()
    }
    
    func requestJSON(path: String, query: [String:String] = [:]) -> Promise<JSON> {
        return requestJSON(get(path: path, query: query))
    }
    
    func requestJSON(request: NSURLRequest) -> Promise<JSON> {
        return requestContent(request, validator: JSONValidator, parser: parseJSON)
    }

    func requestContent<ContentType>(request: NSURLRequest, validator: (NSHTTPURLResponse) -> Validator, parser: (NSData) -> ParseResult<ContentType>) -> Promise<ContentType> {
        let queue = parseQueue
        return promise(request).when { (response, data) in
//            println(response)
            if let error = validator(response).validate() {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                return .Failure(error)
            } else {
                return .Deferred(asyncParse(on: queue, input: data, parser: parser))
            }
        }
    }
    
    func request(method: String, url: NSURL, body: NSData? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        if let nonNilBody = body {
            request.HTTPBody = nonNilBody
        }
        if countElements(userAgent) > 0 {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        for (name, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }
    
    func get(url: NSURL) -> NSMutableURLRequest {
        return request("GET", url: url)
    }
    
    func get(path: String = "", query: [String:String] = [:], fragment: String = "") -> NSMutableURLRequest {
        return get(url(path: path, query: query, fragment: fragment))
    }
    
    func post(url: NSURL, body: NSData? = nil) -> NSMutableURLRequest {
        return request("POST", url: url, body: body)
    }
    
    func post(path: String = "", body: NSData? = nil, query: [String:String] = [:], fragment: String = "") -> NSMutableURLRequest {
        return post(url(path: path, query: query, fragment: fragment), body: body)
    }
    
    func promise(request: NSURLRequest) -> Promise<(response: NSHTTPURLResponse, data: NSData)> {
        return factory.promise(request).when { (response, data) -> Result<(response: NSHTTPURLResponse, data: NSData)> in
            if let httpResponse = response as? NSHTTPURLResponse {
                return .Success((response: httpResponse, data: data))
            } else {
                return .Failure(NotHTTPResponseError())
            }
        }
    }
    
    func url(path: String = "", query: [String:String] = [:], fragment: String = "") -> NSURL {
        let components = NSURLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        if port > 0 {
            components.port = port
        }
        if countElements(query) > 0 {
            components.queryItems = HTTP.queryItems(query)
        }
        if countElements(fragment) > 0 {
            components.fragment = fragment
        }
        return components.URL!
    }
    
    var scheme: String {
        return secure ? "https" : "http"
    }
    
    func clearAllCookies() {
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = cookieStorage.cookies as? [NSHTTPCookie] {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    
    class func formURLencoded(parameters: [String:String], encoding: UInt = NSUTF8StringEncoding) -> NSData {
        let components = NSURLComponents()
        components.queryItems = queryItems(parameters)
        if let query = components.query?.dataUsingEncoding(encoding, allowLossyConversion: false) {
            return query
        } else {
            return NSData()
        }
    }
    
    class func queryItems(query: [String:String]) -> [NSURLQueryItem] {
        var queryItems = [NSURLQueryItem]()
        for (name, value) in query {
            queryItems.append(NSURLQueryItem(name: name, value: value))
        }
        return queryItems
    }
}
