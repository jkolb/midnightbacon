//
//  Keychain.swift
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

import Security
import Foundation

public protocol KeychainItem : CustomStringConvertible {
    func classValue() -> NSString
    func attributes() -> NSDictionary
}

public enum KeychainError : ErrorType {
    case Status(OSStatus)
}

extension NSDictionary {
    public func extractAccessible(key: Keychain.AttributeKey) -> Keychain.Accessible? {
        if let value: AnyObject = self[key.stringValue()] {
            return Keychain.Accessible(value: value as! CFString)
        } else {
            return nil
        }
    }
    
    public func extractString(key: Keychain.AttributeKey) -> String? {
        if let value: AnyObject = self[key.stringValue()] {
            return value as? String
        } else {
            return nil
        }
    }
}

extension NSMutableDictionary {
    public subscript(key: Keychain.UseKey) -> AnyObject? {
        get {
            return self[key.stringValue()]
        }
        set {
            self[key.stringValue()] = newValue
        }
    }
    
    public subscript(key: Keychain.MatchKey) -> AnyObject? {
        get {
            return self[key.stringValue()]
        }
        set {
            self[key.stringValue()] = newValue
        }
    }
    
    public subscript(key: Keychain.ReturnKey) -> AnyObject? {
        get {
            return self[key.stringValue()]
        }
        set {
            self[key.stringValue()] = newValue
        }
    }
    
    public subscript(key: Keychain.ValueKey) -> AnyObject? {
        get {
            return self[key.stringValue()]
        }
        set {
            self[key.stringValue()] = newValue
        }
    }
    
    public subscript(key: Keychain.DictionaryKey) -> AnyObject? {
        get {
            return self[key.stringValue()]
        }
        set {
            self[key.stringValue()] = newValue
        }
    }
    
    public subscript(key: Keychain.AttributeKey) -> AnyObject? {
        get {
            return self[key.stringValue()]
        }
        set {
            self[key.stringValue()] = newValue
        }
    }
}

//public let FailedToAllocate = Keychain.Status(value: errSecAllocate, message: "Failed to allocate memory.")
//public let AuthenticationFailed = Keychain.Status(value: errSecAuthFailed, message: "The user name or passphrase you entered is not correct.")
//public let UnableToDecode = Keychain.Status(value: errSecDecode, message: "Unable to decode the provided data.")
//public let DuplicateItem = Keychain.Status(value: errSecDuplicateItem, message: "The specified item already exists in the keychain.")
//public let InteractionNotAllowed = Keychain.Status(value: errSecInteractionNotAllowed, message: "User interaction is not allowed.")
//public let ItemNotFound = Keychain.Status(value: errSecItemNotFound, message: "The specified item could not be found in the keychain.")
//public let NotAvailable = Keychain.Status(value: errSecNotAvailable, message: "No keychain is available. You may need to restart your computer.")
//public let InvalidParameter = Keychain.Status(value: errSecParam, message: "One or more parameters passed to a function where not valid.")
//public let Success = Keychain.Status(value: errSecSuccess, message: "No error.")
//public let Unimplemented = Keychain.Status(value: errSecUnimplemented, message: "Function or operation not implemented.")
//public let IOError = Keychain.Status(value: errSecIO, message: "I/O error (bummers)")
//public let AlreadyOpenForWrite = Keychain.Status(value: errSecOpWr, message: "file already open with with write permission")
//public let UserCanceled = Keychain.Status(value: errSecUserCanceled, message: "User canceled the operation.")
//public let BadRequest = Keychain.Status(value: errSecBadReq, message: "Bad parameter or invalid state for operation.")
//public let InternalComponent = Keychain.Status(value: errSecInternalComponent)

public class Keychain {
    public init() { }

    public struct Accessible {
        static let WhenUnlocked = Accessible(value: kSecAttrAccessibleWhenUnlocked)
        static let AfterFirstUnlock = Accessible(value: kSecAttrAccessibleAfterFirstUnlock)
        static let Always = Accessible(value: kSecAttrAccessibleAlways)
        static let WhenPasscodeSetThisDeviceOnly = Accessible(value: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        static let WhenUnlockedThisDeviceOnly = Accessible(value: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        static let AfterFirstUnlockThisDeviceOnly = Accessible(value: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        static let AlwaysThisDeviceOnly = Accessible(value: kSecAttrAccessibleAlwaysThisDeviceOnly)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public class GenericPassword : KeychainItem {
        public var accessible: Accessible?
        public var accessControl: Int?
        public var accessGroup: String?
        public var label: String?
        public var creationDate: NSDate? // read-only
        public var modificationDate: NSDate? // read-only
        public var itemDescription: String?
        public var comment: String?
        public var creator: UInt32?
        public var itemType: UInt32?
        public var isInvisible: Bool?
        public var isNegative: Bool?
        public var account: String? // Primary key
        public var service: String? // Primary key
        public var generic: NSData?
        
        public init() { }
        
        public var description: String {
            return "GenericPassword(\(service), \(account))"
        }
        
        public func classValue() -> NSString {
            return kSecClassGenericPassword as NSString
        }
        
        public func attributes() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 13)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            if let value = itemDescription { dictionary[AttributeKey.Description] = value }
            if let value = comment { dictionary[AttributeKey.Comment] = value }
            //            if let value = creator { dictionary[AttributeKey.Creator] = value }
            //            if let value = itemType { dictionary[AttributeKey.ItemType] = value }
            if let value = isInvisible { dictionary[AttributeKey.IsInvisible] = value }
            if let value = isNegative { dictionary[AttributeKey.IsNegative] = value }
            if let value = account { dictionary[AttributeKey.Account] = value }
            if let value = service { dictionary[AttributeKey.Service] = value }
            if let value = generic { dictionary[AttributeKey.Generic] = value }
            
            return dictionary
        }
        
        public class func transform(dictionary: NSDictionary) -> GenericPassword {
            let item = GenericPassword()
            item.accessible = dictionary.extractAccessible(AttributeKey.Accessible)
            item.accessGroup = dictionary.extractString(AttributeKey.AccessGroup)
            item.label = dictionary.extractString(AttributeKey.Label)
            item.itemDescription = dictionary.extractString(AttributeKey.Description)
            item.comment = dictionary.extractString(AttributeKey.Comment)
            item.account = dictionary.extractString(AttributeKey.Account)
            item.service = dictionary.extractString(AttributeKey.Service)
            return item
        }
    }
    
    public struct InternetProtocol {
        public static let FTP = InternetProtocol(value: kSecAttrProtocolFTP)
        public static let FTPAccount = InternetProtocol(value: kSecAttrProtocolFTPAccount)
        public static let HTTP = InternetProtocol(value: kSecAttrProtocolHTTP)
        public static let IRC = InternetProtocol(value: kSecAttrProtocolIRC)
        public static let NNTP = InternetProtocol(value: kSecAttrProtocolNNTP)
        public static let POP3 = InternetProtocol(value: kSecAttrProtocolPOP3)
        public static let SMTP = InternetProtocol(value: kSecAttrProtocolSMTP)
        public static let SOCKS = InternetProtocol(value: kSecAttrProtocolSOCKS)
        public static let IMAP = InternetProtocol(value: kSecAttrProtocolIMAP)
        public static let LDAP = InternetProtocol(value: kSecAttrProtocolLDAP)
        public static let AppleTalk = InternetProtocol(value: kSecAttrProtocolAppleTalk)
        public static let AFP = InternetProtocol(value: kSecAttrProtocolAFP)
        public static let Telnet = InternetProtocol(value: kSecAttrProtocolTelnet)
        public static let SSH = InternetProtocol(value: kSecAttrProtocolSSH)
        public static let FTPS = InternetProtocol(value: kSecAttrProtocolFTPS)
        public static let HTTPS = InternetProtocol(value: kSecAttrProtocolHTTPS)
        public static let HTTPProxy = InternetProtocol(value: kSecAttrProtocolHTTPProxy)
        public static let HTTPSProxy = InternetProtocol(value: kSecAttrProtocolHTTPSProxy)
        public static let FTPProxy = InternetProtocol(value: kSecAttrProtocolFTPProxy)
        public static let SMB = InternetProtocol(value: kSecAttrProtocolSMB)
        public static let RTSP = InternetProtocol(value: kSecAttrProtocolRTSP)
        public static let RTSPProxy = InternetProtocol(value: kSecAttrProtocolRTSPProxy)
        public static let DAAP = InternetProtocol(value: kSecAttrProtocolDAAP)
        public static let EPPC = InternetProtocol(value: kSecAttrProtocolEPPC)
        public static let IPP = InternetProtocol(value: kSecAttrProtocolIPP)
        public static let NNTPS = InternetProtocol(value: kSecAttrProtocolNNTPS)
        public static let LDAPS = InternetProtocol(value: kSecAttrProtocolLDAPS)
        public static let TelnetS = InternetProtocol(value: kSecAttrProtocolTelnetS)
        public static let IMAPS = InternetProtocol(value: kSecAttrProtocolIMAPS)
        public static let IRCS = InternetProtocol(value: kSecAttrProtocolIRCS)
        public static let POP3S = InternetProtocol(value: kSecAttrProtocolPOP3S)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public struct AuthenticationType {
        public static let NTLM = AuthenticationType(value: kSecAttrAuthenticationTypeNTLM)
        public static let MSN = AuthenticationType(value: kSecAttrAuthenticationTypeMSN)
        public static let DPA = AuthenticationType(value: kSecAttrAuthenticationTypeDPA)
        public static let RPA = AuthenticationType(value: kSecAttrAuthenticationTypeRPA)
        public static let HTTPBasic = AuthenticationType(value: kSecAttrAuthenticationTypeHTTPBasic)
        public static let HTTPDigest = AuthenticationType(value: kSecAttrAuthenticationTypeHTTPDigest)
        public static let HTMLForm = AuthenticationType(value: kSecAttrAuthenticationTypeHTMLForm)
        public static let Default = AuthenticationType(value: kSecAttrAuthenticationTypeDefault)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public struct DictionaryKey {
        public static let Class = DictionaryKey(value: kSecClass)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public struct AttributeKey {
        public static let Accessible = AttributeKey(value: kSecAttrAccessible)
        public static let AccessControl = AttributeKey(value: kSecAttrAccessControl)
        public static let AccessGroup = AttributeKey(value: kSecAttrAccessGroup)
        public static let CreationDate = AttributeKey(value: kSecAttrCreationDate)
        public static let ModificationDate = AttributeKey(value: kSecAttrModificationDate)
        public static let Description = AttributeKey(value: kSecAttrDescription)
        public static let Comment = AttributeKey(value: kSecAttrComment)
        public static let Creator = AttributeKey(value: kSecAttrCreator)
        public static let ItemType = AttributeKey(value: kSecAttrType)
        public static let Label = AttributeKey(value: kSecAttrLabel)
        public static let IsInvisible = AttributeKey(value: kSecAttrIsInvisible)
        public static let IsNegative = AttributeKey(value: kSecAttrIsNegative)
        public static let Account = AttributeKey(value: kSecAttrAccount)
        public static let SecurityDomain = AttributeKey(value: kSecAttrSecurityDomain)
        public static let Server = AttributeKey(value: kSecAttrServer)
        public static let InternetProtocol = AttributeKey(value: kSecAttrProtocol)
        public static let AuthenticationType = AttributeKey(value: kSecAttrAuthenticationType)
        public static let Port = AttributeKey(value: kSecAttrPort)
        public static let Path = AttributeKey(value: kSecAttrPath)
        public static let Service = AttributeKey(value: kSecAttrService)
        public static let Generic = AttributeKey(value: kSecAttrGeneric)
        public static let CertificateType = AttributeKey(value: kSecAttrCertificateType)
        public static let CertificateEncoding = AttributeKey(value: kSecAttrCertificateEncoding)
        public static let Subject = AttributeKey(value: kSecAttrSubject)
        public static let Issuer = AttributeKey(value: kSecAttrIssuer)
        public static let SerialNumber = AttributeKey(value: kSecAttrSerialNumber)
        public static let SubjectKeyID = AttributeKey(value: kSecAttrSubjectKeyID)
        public static let PublicKeyHash = AttributeKey(value: kSecAttrPublicKeyHash)
        public static let KeyClass = AttributeKey(value: kSecAttrKeyClass)
        public static let ApplicationLabel = AttributeKey(value: kSecAttrApplicationLabel)
        public static let IsPermanent = AttributeKey(value: kSecAttrIsPermanent)
        public static let ApplicationTag = AttributeKey(value: kSecAttrApplicationTag)
        public static let KeyType = AttributeKey(value: kSecAttrKeyType)
        public static let KeySizeInBits = AttributeKey(value: kSecAttrKeySizeInBits)
        public static let EffectiveKeySize = AttributeKey(value: kSecAttrEffectiveKeySize)
        public static let CanEncrypt = AttributeKey(value: kSecAttrCanEncrypt)
        public static let CanDecrypt = AttributeKey(value: kSecAttrCanDecrypt)
        public static let CanDerive = AttributeKey(value: kSecAttrCanDerive)
        public static let CanSign = AttributeKey(value: kSecAttrCanSign)
        public static let CanVerify = AttributeKey(value: kSecAttrCanVerify)
        public static let CanWrap = AttributeKey(value: kSecAttrCanWrap)
        public static let CanUnwrap = AttributeKey(value: kSecAttrCanUnwrap)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    //    func SecAccessControlCreateWithFlags(allocator: CFAllocator!, protection: AnyObject!, flags: SecAccessControlCreateFlags, error: UnsafeMutablePointer<Unmanaged<CFError>?>) -> Unmanaged<SecAccessControl>!
    
    public class InternetPassword : KeychainItem {
        public var accessible: Accessible?
        public var accessControl: SecAccessControl?
        public var accessGroup: String?
        public var label: String?
        public var creationDate: NSDate? // read-only
        public var modificationDate: NSDate? // read-only
        public var itemDescription: String?
        public var comment: String?
        public var creator: UInt32?
        public var itemType: UInt32?
        public var isInvisible: Bool?
        public var isNegative: Bool?
        public var account: String? // Primary key
        public var securityDomain: String? // Primary key
        public var server: String? // Primary key
        public var internetProtocol: InternetProtocol? // Primary key
        public var authenticationType: AuthenticationType? // Primary key
        public var port: UInt? // Primary key
        public var path: String? // Primary key
        
        public init() { }
        
        public var description: String {
            return "InternetPassword"
        }

        public func classValue() -> NSString {
            return kSecClassInternetPassword as NSString
        }
        
        public func attributes() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 17)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            if let value = itemDescription { dictionary[AttributeKey.Description] = value }
            if let value = comment { dictionary[AttributeKey.Comment] = value }
            //            if let value = creator { dictionary[AttributeKey.Creator] = value }
            //            if let value = itemType { dictionary[AttributeKey.ItemType] = value }
            if let value = isInvisible { dictionary[AttributeKey.IsInvisible] = value }
            if let value = isNegative { dictionary[AttributeKey.IsNegative] = value }
            if let value = account { dictionary[AttributeKey.Account] = value }
            if let value = securityDomain { dictionary[AttributeKey.SecurityDomain] = value }
            if let value = server { dictionary[AttributeKey.Server] = value }
            if let value = internetProtocol { dictionary[AttributeKey.InternetProtocol] = value.stringValue() }
            if let value = authenticationType { dictionary[AttributeKey.AuthenticationType] = value.stringValue() }
            if let value = port { dictionary[AttributeKey.Port] = value }
            if let value = path { dictionary[AttributeKey.Path] = value }
            
            return dictionary
        }
    }
    
    public class Certificate : KeychainItem {
        public var accessible: Accessible?
        public var accessControl: SecAccessControl?
        public var accessGroup: String?
        public var label: String?
        public var certificateType: UInt? // read-only Primary key
        public var certificateEncoding: Int? // read-only
        public var subject: NSData? // read-only
        public var issuer: NSData? // read-only Primary key
        public var serialNumber: NSData? // read-only Primary key
        public var subjectKeyID: NSData? // read-only
        public var publicKeyHash: NSData? // read-only
        
        public init() { }
        
        public var description: String {
            return "Certificate"
        }

        public func classValue() -> NSString {
            return kSecClassCertificate as NSString
        }
        
        public func attributes() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 4)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            
            return dictionary
        }
    }
    
    public struct KeyClass {
        public static let Public = KeyClass(value: kSecAttrKeyClassPublic)
        public static let Private = KeyClass(value: kSecAttrKeyClassPrivate)
        public static let Symmetric = KeyClass(value: kSecAttrKeyClassSymmetric)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public class Key : KeychainItem {
        public var accessible: Accessible?
        public var accessControl: SecAccessControl?
        public var accessGroup: String?
        public var label: String?
        public var keyClass: KeyClass?
        public var applicationLabel: NSData? // Primary key
        public var isPermanent: Bool?
        public var applicationTag: NSData? // Primary key
        public var keyType: String? // Primary key
        public var keySizeInBits: UInt? // Primary key
        public var effectiveKeySize: UInt? // Primary key
        public var canEncrypt: Bool?
        public var canDecrypt: Bool?
        public var canDerive: Bool?
        public var canSign: Bool?
        public var canVerify: Bool?
        public var canWrap: Bool?
        public var canUnwrap: Bool?
        
        public init() { }
        
        public var description: String {
            return "Key"
        }

        public func classValue() -> NSString {
            return kSecClassKey as NSString
        }
        
        public func attributes() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 18)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            if let value = keyClass { dictionary[AttributeKey.KeyClass] = value.stringValue() }
            if let value = applicationLabel { dictionary[AttributeKey.ApplicationLabel] = value }
            if let value = isPermanent { dictionary[AttributeKey.IsPermanent] = value }
            if let value = applicationTag { dictionary[AttributeKey.ApplicationTag] = value }
            if let value = keyType { dictionary[AttributeKey.KeyType] = value }
            if let value = keySizeInBits { dictionary[AttributeKey.KeySizeInBits] = value }
            if let value = effectiveKeySize { dictionary[AttributeKey.EffectiveKeySize] = value }
            if let value = canEncrypt { dictionary[AttributeKey.CanEncrypt] = value }
            if let value = canDecrypt { dictionary[AttributeKey.CanDecrypt] = value }
            if let value = canDerive { dictionary[AttributeKey.CanDerive] = value }
            if let value = canSign { dictionary[AttributeKey.CanSign] = value }
            if let value = canVerify { dictionary[AttributeKey.CanVerify] = value }
            if let value = canWrap { dictionary[AttributeKey.CanWrap] = value }
            if let value = canUnwrap { dictionary[AttributeKey.CanUnwrap] = value }
            
            return dictionary
        }
    }
    
    public class Identity : KeychainItem {
        public var accessible: Accessible?
        public var accessControl: SecAccessControl?
        public var accessGroup: String?
        public var label: String?
        public var certificateType: UInt? // read-only
        public var certificateEncoding: Int? // read-only
        public var subject: NSData? // read-only
        public var issuer: NSData? // read-only
        public var serialNumber: NSData? // read-only
        public var subjectKeyID: NSData? // read-only
        public var publicKeyHash: NSData? // read-only
        public var keyClass: KeyClass?
        public var applicationLabel: NSData?
        public var isPermanent: Bool?
        public var applicationTag: NSData?
        public var keyType: UInt?
        public var keySizeInBits: UInt?
        public var effectiveKeySize: UInt?
        public var canEncrypt: Bool?
        public var canDecrypt: Bool?
        public var canDerive: Bool?
        public var canSign: Bool?
        public var canVerify: Bool?
        public var canWrap: Bool?
        public var canUnwrap: Bool?
        
        public init() { }
        
        public var description: String {
            return "Identity"
        }

        public func classValue() -> NSString {
            return kSecClassIdentity as NSString
        }
        
        public func attributes() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 18)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            if let value = keyClass { dictionary[AttributeKey.KeyClass] = value.stringValue() }
            if let value = applicationLabel { dictionary[AttributeKey.ApplicationLabel] = value }
            if let value = isPermanent { dictionary[AttributeKey.IsPermanent] = value }
            if let value = applicationTag { dictionary[AttributeKey.ApplicationTag] = value }
            if let value = keyType { dictionary[AttributeKey.KeyType] = value }
            if let value = keySizeInBits { dictionary[AttributeKey.KeySizeInBits] = value }
            if let value = effectiveKeySize { dictionary[AttributeKey.EffectiveKeySize] = value }
            if let value = canEncrypt { dictionary[AttributeKey.CanEncrypt] = value }
            if let value = canDecrypt { dictionary[AttributeKey.CanDecrypt] = value }
            if let value = canDerive { dictionary[AttributeKey.CanDerive] = value }
            if let value = canSign { dictionary[AttributeKey.CanSign] = value }
            if let value = canVerify { dictionary[AttributeKey.CanVerify] = value }
            if let value = canWrap { dictionary[AttributeKey.CanWrap] = value }
            if let value = canUnwrap { dictionary[AttributeKey.CanUnwrap] = value }
            
            return dictionary
        }
    }
    
    public struct MatchKey {
        public static let Policy = MatchKey(value: kSecMatchPolicy)
        public static let ItemList = MatchKey(value: kSecMatchItemList)
        public static let SearchList = MatchKey(value: kSecMatchSearchList)
        public static let Issuers = MatchKey(value: kSecMatchIssuers)
        public static let EmailAddressIfPresent = MatchKey(value: kSecMatchEmailAddressIfPresent)
        public static let SubjectContains = MatchKey(value: kSecMatchSubjectContains)
        public static let CaseInsensitive = MatchKey(value: kSecMatchCaseInsensitive)
        public static let TrustedOnly = MatchKey(value: kSecMatchTrustedOnly)
        public static let ValidOnDate = MatchKey(value: kSecMatchValidOnDate)
        public static let Limit = MatchKey(value: kSecMatchLimit)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public class Search {
        public var policy: SecPolicy?
        public var issuers: [NSData]?
        public var emailAddresses: [String]?
        public var subject: String?
        public var caseInsensitive: Bool?
        public var trustedOnly: Bool?
        public var validOnDate: NSDate?
        public var limit: UInt?
        
        public func attributes() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 8)
            
            if let value = policy { dictionary[MatchKey.Policy] = value }
            if let value = issuers { dictionary[MatchKey.Issuers] = value }
            if let value = emailAddresses { dictionary[MatchKey.EmailAddressIfPresent] = value }
            if let value = subject { dictionary[MatchKey.SubjectContains] = value }
            if let value = caseInsensitive { dictionary[MatchKey.CaseInsensitive] = value }
            if let value = trustedOnly { dictionary[MatchKey.TrustedOnly] = value }
            if let value = validOnDate { dictionary[MatchKey.ValidOnDate] = value }
            if let value = limit {
                if value == 0 {
                    dictionary[MatchKey.Limit] = kSecMatchLimitAll
                } else if value == 1 {
                    dictionary[MatchKey.Limit] = kSecMatchLimitOne
                } else {
                    dictionary[MatchKey.Limit] = value
                }
            }
            
            return dictionary
        }
        
        public class func all() -> Search {
            let search = Search()
            search.limit = 0
            return search
        }
    }
    
    public struct ReturnKey {
        public static let Data = ReturnKey(value: kSecReturnData)
        public static let Attributes = ReturnKey(value: kSecReturnAttributes)
        public static let Reference = ReturnKey(value: kSecReturnRef)
        public static let PersistentReference = ReturnKey(value: kSecReturnPersistentRef)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public struct ValueKey {
        public static let Data = ValueKey(value: kSecValueData)
        public static let Reference = ValueKey(value: kSecValueRef)
        public static let PersistentReference = ValueKey(value: kSecValuePersistentRef)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public struct UseKey {
        public static let ItemList = UseKey(value: kSecUseItemList)
        public static let OperationPrompt = UseKey(value: kSecUseOperationPrompt)
        public static let NoAuthenticationUI = UseKey(value: kSecUseNoAuthenticationUI)
        public static let AuthenticationUI = UseKey(value: kSecUseAuthenticationUI)
        public static let AuthenticationContext = UseKey(value: kSecUseAuthenticationContext)
        
        public let value: CFStringRef
        
        public func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    public func lookupAttributes<T: KeychainItem>(queryItem: T, search: Search, transform: (NSDictionary) -> T) throws -> [T] {
        let query = NSMutableDictionary(dictionary: queryItem.attributes() as [NSObject:AnyObject])
        query.addEntriesFromDictionary(search.attributes() as [NSObject:AnyObject])
        query[DictionaryKey.Class] = queryItem.classValue()
        query[ReturnKey.Attributes] = true
        var object: AnyObject?
        let status = SecItemCopyMatching(query, &object)
        
        if status == errSecSuccess {
            if let array = object as? NSArray {
                let dictionaries = array as! [NSDictionary]
                return dictionaries.map(transform)
            } else {
                let dictionary = object as! NSDictionary
                return [transform(dictionary)]
            }
        } else {
            throw KeychainError.Status(status)
        }
    }
    
    public func lookupData(queryItem: KeychainItem, search: Search = Search()) throws -> [NSData] {
        let query = NSMutableDictionary(dictionary: queryItem.attributes() as [NSObject:AnyObject])
        query.addEntriesFromDictionary(search.attributes() as [NSObject:AnyObject])
        query[DictionaryKey.Class] = queryItem.classValue()
        query[ReturnKey.Data] = true
        var object: AnyObject?
        let status = SecItemCopyMatching(query, &object)
        
        if status == errSecSuccess {
            if let array = object as? NSArray {
                let data = array as! [NSData]
                return data
            } else {
                let data = object as! NSData
                return [data]
            }
        } else {
            throw KeychainError.Status(status)
        }
    }
    
    public func addData(addItem: KeychainItem, data: NSData) throws {
        let attributes = NSMutableDictionary(dictionary: addItem.attributes() as [NSObject:AnyObject])
        attributes[DictionaryKey.Class] = addItem.classValue()
        attributes[ValueKey.Data] = data
        let status = SecItemAdd(attributes, nil)
        if status != errSecSuccess{
            throw KeychainError.Status(status)
        }
    }
    
    public func update(queryItem: KeychainItem, updateItem: KeychainItem, search: Search = Search()) throws {
        let query = NSMutableDictionary(dictionary: queryItem.attributes() as [NSObject:AnyObject])
        query.addEntriesFromDictionary(search.attributes() as [NSObject:AnyObject])
        query[DictionaryKey.Class] = queryItem.classValue()
        let attributes = updateItem.attributes()
        let status = SecItemUpdate(query, attributes)
        if status != errSecSuccess {
            throw KeychainError.Status(status)
        }
    }
    
    public func delete(queryItem: KeychainItem, search: Search = Search()) throws {
        let query = NSMutableDictionary(dictionary: queryItem.attributes() as [NSObject:AnyObject])
        query.addEntriesFromDictionary(search.attributes() as [NSObject:AnyObject])
        query[DictionaryKey.Class] = queryItem.classValue()
        let status = SecItemDelete(query)
        if status != errSecSuccess {
            throw KeychainError.Status(status)
        }
    }
    
    public func clear() {
        let keychainItems: [KeychainItem] = [
            GenericPassword(),
            InternetPassword(),
            Certificate(),
            Key(),
            Identity(),
        ]
        for keychainItem in keychainItems {
            let query = NSMutableDictionary()
            query[DictionaryKey.Class] = keychainItem.classValue()
            SecItemDelete(query)
        }
    }
    
    public func loadGenericPassword(service service: String, account: String) throws -> NSData {
        let sessionItem = GenericPassword()
        sessionItem.account = account
        sessionItem.service = service
        let result = try lookupData(sessionItem)
        return result.first!
    }
    
    public func findGenericPassword(service service: String, limit: UInt = 0) throws -> [GenericPassword] {
        let sessionItem = GenericPassword()
        sessionItem.service = service
        let search = Search()
        search.limit = limit
        do {
            return try lookupAttributes(sessionItem, search: search, transform: GenericPassword.transform)
        }
        catch KeychainError.Status(let status) {
            if status == errSecItemNotFound {
                return []
            }
            else {
                throw KeychainError.Status(status)
            }
        }
    }
    
    public func saveGenericPassword(service service: String, account: String, data: NSData) throws {
        let sessionItem = GenericPassword()
        sessionItem.account = account
        sessionItem.service = service
        try delete(sessionItem)
        try addData(sessionItem, data: data)
    }
    
    public func deleteGenericPassword(service service: String, account: String) throws {
        let sessionItem = GenericPassword()
        sessionItem.account = account
        sessionItem.service = service
        try delete(sessionItem)
    }
}
