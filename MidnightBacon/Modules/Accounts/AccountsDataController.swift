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

import FranticApparatus

public enum AccountMenuEvent {
    case AddAccount
    case LurkerMode
    case SwitchToUsername(String)
    case Unimplemented
}

public protocol AccountsDataControllerDelegate : class {
    func accountsDataController(dataController: AccountsDataController, didLoadMenu menu: Menu<AccountMenuEvent>)
}

public class AccountsDataController {
    private var insecureStore: InsecureStore
    private var secureStore: SecureStore
    public weak var delegate: AccountsDataControllerDelegate?
    
    public init(insecureStore: InsecureStore, secureStore: SecureStore) {
        self.insecureStore = insecureStore
        self.secureStore = secureStore
    }
    
    private var menuPromise: Promise<Menu<AccountMenuEvent>>?
    
    public func reloadMenu() {
        menuPromise = loadMenu().thenWithContext(self, { (strongSelf, menu) -> Void in
            strongSelf.delegate?.accountsDataController(strongSelf, didLoadMenu: menu)
        }).handleWithContext(self, { (strongSelf, error) -> Void in
            fatalError("Unexpected error: \(error)")
        }).finallyWithContext(self, { (strongSelf) in
            strongSelf.menuPromise = nil
        })
    }
    
    private var lastAuthenticatedUsername: String {
        return insecureStore.lastAuthenticatedUsername ?? ""
    }
    
    private func loadMenu() -> Promise<Menu<AccountMenuEvent>> {
        return secureStore.findUsernames().thenWithContext(self, { (strongSelf, usernames) -> Menu<AccountMenuEvent> in
            let menuBuilder = AccountsMenuBuilder(
                usernames: usernames,
                lastAuthenticatedUsername: strongSelf.lastAuthenticatedUsername
            )
            return menuBuilder.build()
        })
    }
}
