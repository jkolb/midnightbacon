//
//  SecureStore.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/9/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation

protocol SecureStore {
    
}

protocol SecureItem {
    func classValue() -> NSString
    func dictionaryValue() -> NSDictionary
}

func ==(lhs: Keychain.Status, rhs: Keychain.Status) -> Bool {
    return lhs.value == rhs.value
}

extension NSDictionary {
    func extractAccessible(key: Keychain.AttributeKey) -> Keychain.Accessible? {
        if let value: AnyObject = self[key.stringValue()] {
            return Keychain.Accessible(value: value as CFString)
        } else {
            return nil
        }
    }
    
    func extractString(key: Keychain.AttributeKey) -> String? {
        if let value: AnyObject = self[key.stringValue()] {
            return value as? String
        } else {
            return nil
        }
    }
}

extension NSMutableDictionary {
    subscript(key: Keychain.AttributeKey) -> AnyObject? {
        get {
            return self[key.stringValue()]
        }
        set {
            self[key.stringValue()] = newValue
        }
    }
}

//            if let value = accessible { dictionary[AttributeKey.Accessible.stringValue()] = value.stringValue() }

class Keychain : SecureStore {
    struct Status : Equatable {
        static let FailedToAllocate = Status(value: errSecAllocate, message: "Failed to allocate memory.")
        static let AuthenticationFailed = Status(value: errSecAuthFailed, message: "The user name or passphrase you entered is not correct.")
        static let UnableToDecode = Status(value: errSecDecode, message: "Unable to decode the provided data.")
        static let DuplicateItem = Status(value: errSecDuplicateItem, message: "The specified item already exists in the keychain.")
        static let InteractionNotAllowed = Status(value: errSecInteractionNotAllowed, message: "User interaction is not allowed.")
        static let ItemNotFound = Status(value: errSecItemNotFound, message: "The specified item could not be found in the keychain.")
        static let NotAvailable = Status(value: errSecNotAvailable, message: "No keychain is available. You may need to restart your computer.")
        static let InvalidParameter = Status(value: errSecParam, message: "One or more parameters passed to a function where not valid.")
        static let Success = Status(value: errSecSuccess, message: "No error.")
        static let Unimplemented = Status(value: errSecUnimplemented, message: "Function or operation not implemented.")
        static let IOError = Status(value: errSecIO, message: "I/O error (bummers)")
        static let AlreadyOpenForWrite = Status(value: errSecOpWr, message: "file already open with with write permission")
        static let UserCanceled = Status(value: errSecUserCanceled, message: "User canceled the operation.")
        static let BadRequest = Status(value: errSecBadReq, message: "Bad parameter or invalid state for operation.")
        static let InternalComponent = Status(value: errSecInternalComponent)

        static let knownStatus = [
            FailedToAllocate.value: FailedToAllocate,
            AuthenticationFailed.value: AuthenticationFailed,
            UnableToDecode.value: UnableToDecode,
            DuplicateItem.value: DuplicateItem,
            InteractionNotAllowed.value: InteractionNotAllowed,
            ItemNotFound.value: ItemNotFound,
            NotAvailable.value: NotAvailable,
            InvalidParameter.value: InvalidParameter,
            Success.value: Success,
            Unimplemented.value: Unimplemented,
            IOError.value: IOError,
            AlreadyOpenForWrite.value: AlreadyOpenForWrite,
            UserCanceled.value: UserCanceled,
            BadRequest.value: BadRequest,
            InternalComponent.value: InternalComponent,
        ]
        
        static func lookup(value: Int) -> Status {
            if let status = knownStatus[value] {
                return status
            } else {
                return Status(value: value)
            }
        }
        
        static func lookup(value: OSStatus) -> Status {
            return lookup(Int(value))
        }
        
        let value: Int
        let message: String
        
        init(value: OSStatus, message: String = "") {
            self.value = Int(value)
            self.message = message
        }
        
        init(value: Int, message: String = "") {
            self.value = value
            self.message = message
        }
    }

    struct Accessible {
        static let WhenUnlocked = Accessible(value: kSecAttrAccessibleWhenUnlocked)
        static let AfterFirstUnlock = Accessible(value: kSecAttrAccessibleAfterFirstUnlock)
        static let Always = Accessible(value: kSecAttrAccessibleAlways)
        static let WhenPasscodeSetThisDeviceOnly = Accessible(value: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        static let WhenUnlockedThisDeviceOnly = Accessible(value: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        static let AfterFirstUnlockThisDeviceOnly = Accessible(value: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        static let AlwaysThisDeviceOnly = Accessible(value: kSecAttrAccessibleAlwaysThisDeviceOnly)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    class GenericPassword : SecureItem {
        var accessible: Accessible?
        var accessControl: Int?
        var accessGroup: String?
        var label: String?
        var creationDate: NSDate? // read-only
        var modificationDate: NSDate? // read-only
        var description: String?
        var comment: String?
        var creator: UInt32?
        var itemType: UInt32?
        var isInvisible: Bool?
        var isNegative: Bool?
        var account: String?
        var service: String?
        var generic: NSData?
        
        func classValue() -> NSString {
            return kSecClassGenericPassword as NSString
        }
        
        func dictionaryValue() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 13)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            if let value = description { dictionary[AttributeKey.Description] = value }
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
        
        func extract(dictionary: NSDictionary) {
            accessible = dictionary.extractAccessible(AttributeKey.Accessible)
            accessGroup = dictionary.extractString(AttributeKey.AccessGroup)
        }
    }

    struct InternetProtocol {
        static let FTP = InternetProtocol(value: kSecAttrProtocolFTP)
        static let FTPAccount = InternetProtocol(value: kSecAttrProtocolFTPAccount)
        static let HTTP = InternetProtocol(value: kSecAttrProtocolHTTP)
        static let IRC = InternetProtocol(value: kSecAttrProtocolIRC)
        static let NNTP = InternetProtocol(value: kSecAttrProtocolNNTP)
        static let POP3 = InternetProtocol(value: kSecAttrProtocolPOP3)
        static let SMTP = InternetProtocol(value: kSecAttrProtocolSMTP)
        static let SOCKS = InternetProtocol(value: kSecAttrProtocolSOCKS)
        static let IMAP = InternetProtocol(value: kSecAttrProtocolIMAP)
        static let LDAP = InternetProtocol(value: kSecAttrProtocolLDAP)
        static let AppleTalk = InternetProtocol(value: kSecAttrProtocolAppleTalk)
        static let AFP = InternetProtocol(value: kSecAttrProtocolAFP)
        static let Telnet = InternetProtocol(value: kSecAttrProtocolTelnet)
        static let SSH = InternetProtocol(value: kSecAttrProtocolSSH)
        static let FTPS = InternetProtocol(value: kSecAttrProtocolFTPS)
        static let HTTPS = InternetProtocol(value: kSecAttrProtocolHTTPS)
        static let HTTPProxy = InternetProtocol(value: kSecAttrProtocolHTTPProxy)
        static let HTTPSProxy = InternetProtocol(value: kSecAttrProtocolHTTPSProxy)
        static let FTPProxy = InternetProtocol(value: kSecAttrProtocolFTPProxy)
        static let SMB = InternetProtocol(value: kSecAttrProtocolSMB)
        static let RTSP = InternetProtocol(value: kSecAttrProtocolRTSP)
        static let RTSPProxy = InternetProtocol(value: kSecAttrProtocolRTSPProxy)
        static let DAAP = InternetProtocol(value: kSecAttrProtocolDAAP)
        static let EPPC = InternetProtocol(value: kSecAttrProtocolEPPC)
        static let IPP = InternetProtocol(value: kSecAttrProtocolIPP)
        static let NNTPS = InternetProtocol(value: kSecAttrProtocolNNTPS)
        static let LDAPS = InternetProtocol(value: kSecAttrProtocolLDAPS)
        static let TelnetS = InternetProtocol(value: kSecAttrProtocolTelnetS)
        static let IMAPS = InternetProtocol(value: kSecAttrProtocolIMAPS)
        static let IRCS = InternetProtocol(value: kSecAttrProtocolIRCS)
        static let POP3S = InternetProtocol(value: kSecAttrProtocolPOP3S)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }

    struct AuthenticationType {
        static let NTLM = AuthenticationType(value: kSecAttrAuthenticationTypeNTLM)
        static let MSN = AuthenticationType(value: kSecAttrAuthenticationTypeMSN)
        static let DPA = AuthenticationType(value: kSecAttrAuthenticationTypeDPA)
        static let RPA = AuthenticationType(value: kSecAttrAuthenticationTypeRPA)
        static let HTTPBasic = AuthenticationType(value: kSecAttrAuthenticationTypeHTTPBasic)
        static let HTTPDigest = AuthenticationType(value: kSecAttrAuthenticationTypeHTTPDigest)
        static let HTMLForm = AuthenticationType(value: kSecAttrAuthenticationTypeHTMLForm)
        static let Default = AuthenticationType(value: kSecAttrAuthenticationTypeDefault)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }

    struct DictionaryKey {
        static let Class = DictionaryKey(value: kSecClass)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    struct AttributeKey {
        static let Accessible = AttributeKey(value: kSecAttrAccessible)
        static let AccessControl = AttributeKey(value: kSecAttrAccessControl)
        static let AccessGroup = AttributeKey(value: kSecAttrAccessGroup)
        static let CreationDate = AttributeKey(value: kSecAttrCreationDate)
        static let ModificationDate = AttributeKey(value: kSecAttrModificationDate)
        static let Description = AttributeKey(value: kSecAttrDescription)
        static let Comment = AttributeKey(value: kSecAttrComment)
        static let Creator = AttributeKey(value: kSecAttrCreator)
        static let ItemType = AttributeKey(value: kSecAttrType)
        static let Label = AttributeKey(value: kSecAttrLabel)
        static let IsInvisible = AttributeKey(value: kSecAttrIsInvisible)
        static let IsNegative = AttributeKey(value: kSecAttrIsNegative)
        static let Account = AttributeKey(value: kSecAttrAccount)
        static let SecurityDomain = AttributeKey(value: kSecAttrSecurityDomain)
        static let Server = AttributeKey(value: kSecAttrServer)
        static let InternetProtocol = AttributeKey(value: kSecAttrProtocol)
        static let AuthenticationType = AttributeKey(value: kSecAttrAuthenticationType)
        static let Port = AttributeKey(value: kSecAttrPort)
        static let Path = AttributeKey(value: kSecAttrPath)
        static let Service = AttributeKey(value: kSecAttrService)
        static let Generic = AttributeKey(value: kSecAttrGeneric)
        static let CertificateType = AttributeKey(value: kSecAttrCertificateType)
        static let CertificateEncoding = AttributeKey(value: kSecAttrCertificateEncoding)
        static let Subject = AttributeKey(value: kSecAttrSubject)
        static let Issuer = AttributeKey(value: kSecAttrIssuer)
        static let SerialNumber = AttributeKey(value: kSecAttrSerialNumber)
        static let SubjectKeyID = AttributeKey(value: kSecAttrSubjectKeyID)
        static let PublicKeyHash = AttributeKey(value: kSecAttrPublicKeyHash)
        static let KeyClass = AttributeKey(value: kSecAttrKeyClass)
        static let ApplicationLabel = AttributeKey(value: kSecAttrApplicationLabel)
        static let IsPermanent = AttributeKey(value: kSecAttrIsPermanent)
        static let ApplicationTag = AttributeKey(value: kSecAttrApplicationTag)
        static let KeyType = AttributeKey(value: kSecAttrKeyType)
        static let KeySizeInBits = AttributeKey(value: kSecAttrKeySizeInBits)
        static let EffectiveKeySize = AttributeKey(value: kSecAttrEffectiveKeySize)
        static let CanEncrypt = AttributeKey(value: kSecAttrCanEncrypt)
        static let CanDecrypt = AttributeKey(value: kSecAttrCanDecrypt)
        static let CanDerive = AttributeKey(value: kSecAttrCanDerive)
        static let CanSign = AttributeKey(value: kSecAttrCanSign)
        static let CanVerify = AttributeKey(value: kSecAttrCanVerify)
        static let CanWrap = AttributeKey(value: kSecAttrCanWrap)
        static let CanUnwrap = AttributeKey(value: kSecAttrCanUnwrap)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
//    func SecAccessControlCreateWithFlags(allocator: CFAllocator!, protection: AnyObject!, flags: SecAccessControlCreateFlags, error: UnsafeMutablePointer<Unmanaged<CFError>?>) -> Unmanaged<SecAccessControl>!

    class InternetPassword : SecureItem {
        var accessible: Accessible?
        var accessControl: SecAccessControl?
        var accessGroup: String?
        var label: String?
        var creationDate: NSDate? // read-only
        var modificationDate: NSDate? // read-only
        var description: String?
        var comment: String?
        var creator: UInt32?
        var itemType: UInt32?
        var isInvisible: Bool?
        var isNegative: Bool?
        var account: String?
        var securityDomain: String?
        var server: String?
        var internetProtocol: InternetProtocol?
        var authenticationType: AuthenticationType?
        var port: UInt?
        var path: String?
        
        func classValue() -> NSString {
            return kSecClassInternetPassword as NSString
        }
        
        func dictionaryValue() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 17)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            if let value = description { dictionary[AttributeKey.Description] = value }
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
    
    class Certificate : SecureItem {
        var accessible: Accessible?
        var accessControl: SecAccessControl?
        var accessGroup: String?
        var label: String?
        var certificateType: UInt? // read-only
        var certificateEncoding: Int? // read-only
        var subject: NSData? // read-only
        var issuer: NSData? // read-only
        var serialNumber: NSData? // read-only
        var subjectKeyID: NSData? // read-only
        var publicKeyHash: NSData? // read-only
        
        func classValue() -> NSString {
            return kSecClassCertificate as NSString
        }
        
        func dictionaryValue() -> NSDictionary {
            let dictionary = NSMutableDictionary(capacity: 4)
            
            if let value = accessible { dictionary[AttributeKey.Accessible] = value.stringValue() }
            if let value = accessControl { dictionary[AttributeKey.AccessControl] = value }
            if let value = accessGroup { dictionary[AttributeKey.AccessGroup] = value }
            if let value = label { dictionary[AttributeKey.Label] = value }
            
            return dictionary
        }
    }
    
    struct KeyClass {
        static let Public = KeyClass(value: kSecAttrKeyClassPublic)
        static let Private = KeyClass(value: kSecAttrKeyClassPrivate)
        static let Symmetric = KeyClass(value: kSecAttrKeyClassSymmetric)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    class Key : SecureItem {
        var accessible: Accessible?
        var accessControl: SecAccessControl?
        var accessGroup: String?
        var label: String?
        var keyClass: KeyClass?
        var applicationLabel: NSData?
        var isPermanent: Bool?
        var applicationTag: NSData?
        var keyType: String?
        var keySizeInBits: UInt?
        var effectiveKeySize: UInt?
        var canEncrypt: Bool?
        var canDecrypt: Bool?
        var canDerive: Bool?
        var canSign: Bool?
        var canVerify: Bool?
        var canWrap: Bool?
        var canUnwrap: Bool?
        
        func classValue() -> NSString {
            return kSecClassKey as NSString
        }
        
        func dictionaryValue() -> NSDictionary {
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
    
    class Identity : SecureItem {
        var accessible: Accessible?
        var accessControl: SecAccessControl?
        var accessGroup: String?
        var label: String?
        var certificateType: UInt? // read-only
        var certificateEncoding: Int? // read-only
        var subject: NSData? // read-only
        var issuer: NSData? // read-only
        var serialNumber: NSData? // read-only
        var subjectKeyID: NSData? // read-only
        var publicKeyHash: NSData? // read-only
        var keyClass: KeyClass?
        var applicationLabel: NSData?
        var isPermanent: Bool?
        var applicationTag: NSData?
        var keyType: UInt?
        var keySizeInBits: UInt?
        var effectiveKeySize: UInt?
        var canEncrypt: Bool?
        var canDecrypt: Bool?
        var canDerive: Bool?
        var canSign: Bool?
        var canVerify: Bool?
        var canWrap: Bool?
        var canUnwrap: Bool?
        
        func classValue() -> NSString {
            return kSecClassIdentity as NSString
        }
        
        func dictionaryValue() -> NSDictionary {
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
    
    struct Match {
        static let Policy = Match(value: kSecMatchPolicy)
        static let ItemList = Match(value: kSecMatchItemList)
        static let SearchList = Match(value: kSecMatchSearchList)
        static let Issuers = Match(value: kSecMatchIssuers)
        static let EmailAddressIfPresent = Match(value: kSecMatchEmailAddressIfPresent)
        static let SubjectContains = Match(value: kSecMatchSubjectContains)
        static let CaseInsensitive = Match(value: kSecMatchCaseInsensitive)
        static let TrustedOnly = Match(value: kSecMatchTrustedOnly)
        static let ValidOnDate = Match(value: kSecMatchValidOnDate)
        static let Limit = Match(value: kSecMatchLimit)
        static let LimitOne = Match(value: kSecMatchLimitOne)
        static let LimitAll = Match(value: kSecMatchLimitAll)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    struct Return {
        static let Data = Return(value: kSecReturnData)
        static let Attributes = Return(value: kSecReturnAttributes)
        static let Reference = Return(value: kSecReturnRef)
        static let PersistentReference = Return(value: kSecReturnPersistentRef)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    struct Value {
        static let Data = Value(value: kSecValueData)
        static let Reference = Value(value: kSecValueRef)
        static let PersistentReference = Value(value: kSecValuePersistentRef)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    struct Use {
        static let ItemList = Use(value: kSecUseItemList)
        static let OperationPrompt = Use(value: kSecUseOperationPrompt)
        static let NoAuthenticationUI = Use(value: kSecUseNoAuthenticationUI)
        
        let value: CFStringRef
        
        func stringValue() -> NSString {
            return value as NSString
        }
    }
    
    func search(item: SecureItem) {
//        func SecItemCopyMatching(query: CFDictionary!, result: UnsafeMutablePointer<Unmanaged<AnyObject>?>) -> OSStatus
    }
    
    func add(item: SecureItem) {
//        func SecItemAdd(attributes: CFDictionary!, result: UnsafeMutablePointer<Unmanaged<AnyObject>?>) -> OSStatus
    }
    
    func update(item: SecureItem) {
//        func SecItemUpdate(query: CFDictionary!, attributesToUpdate: CFDictionary!) -> OSStatus
    }
    
    func delete(item: SecureItem) {
//        func SecItemDelete(query: CFDictionary!) -> OSStatus
    }
}
