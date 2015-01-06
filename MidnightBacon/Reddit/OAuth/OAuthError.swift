//
//  OAuthError.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/16/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FranticApparatus

class OAuthAccessDeniedError : Error { }
class OAuthUnsupportedResponseTypeError : Error { }
class OAuthInvalidScopeError : Error { }
class OAuthInvalidRequestError : Error { }
class OAuthUnexpectedStateError : Error { }
class OAuthMalformedURLError : Error { }
class OAuthEmptyURLQueryError : Error { }
class OAuthMissingURLQueryError : Error { }
class OAuthMissingURLFragmentError : Error { }
class OAuthUnexpectedErrorStringError : Error { }
class OAuthMissingCodeError : Error { }
