//
//  AccountsFactory.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 12/6/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import FieryCrucible
import UIKit

class AccountsFactory : DependencyFactory {
    var sharedFactory: SharedFactory!
    
    func accountsFlow() -> AccountsFlow {
        return shared(
            "accountsController",
            factory: AccountsFlow(),
            configure: { [unowned self] (instance) in
                instance.accountsFactory = self
            }
        )
    }
    
    func accountsMenuLoader(actions: AccountsActions) -> MenuLoader {
        return unshared(
            "accountsMenuLoader",
            factory: AccountsMenuLoader(),
            configure: { [unowned self] (instance) in
                instance.secureStore = self.sharedFactory.secureStore()
                instance.insecureStore = self.sharedFactory.insecureStore()
                instance.actions = actions
            }
        )
    }

    func addAccountInteractor() -> AddAccountInteractor {
        return scoped(
            "addAccountInteractor",
            factory: AddAccountInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.sharedFactory.gateway()
                instance.secureStore = self.sharedFactory.secureStore()
            }
        )
    }
    
    func redditUserInteractor() -> RedditUserInteractor {
        return scoped(
            "redditUserInteractor",
            factory: RedditUserInteractor(),
            configure: { [unowned self] (instance) in
                instance.gateway = self.sharedFactory.gateway()
                instance.sessionService = self.sharedFactory.sessionService()
            }
        )
    }
}
