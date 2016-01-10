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

import UIKit
import FranticApparatus
import Reddit
import Common

public class AccountsFlowController : NavigationFlowController {
    weak var factory: MainFactory!
    var dataController: AccountsDataController
    var oauthService: OAuthService!
    
    var aboutUserPromise: Promise<Account>!
    var accountsMenuViewController: MenuViewController!
    var addAccountFlowController: OAuthFlowController!
    
    public init(dataController: AccountsDataController) {
        self.dataController = dataController
    }
    
    public override func viewControllerDidLoad() {
        accountsMenuViewController = buildAccountsMenuViewController()
        pushViewController(accountsMenuViewController, animated: false)
    }
    
    public override func flowDidStart(animated: Bool) {
        super.flowDidStart(animated)
        
        dataController.reloadMenu()
    }
    
    func buildAccountsMenuViewController() -> MenuViewController {
        let viewController = MenuViewController()
        viewController.title = "Accounts"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.edit(target: self, action: Selector("editAccounts"))
        return viewController
    }

    func editAccounts() {
    }
    
    func addAccount() {
        if addAccountFlowController != nil { return }
        addAccountFlowController = factory.oauthFlowController()
        addAccountFlowController.delegate = self
        
        presentAndStartFlow(addAccountFlowController)
    }
    
    func lurkerMode() {
        oauthService.lurkerMode()
        dataController.reloadMenu()
    }
    
    func switchToUsername(username: String) {
        oauthService.switchToUsername(username)
        dataController.reloadMenu()
    }
    
    func handleAccountMenuEvent(event: AccountMenuEvent) {
        switch event {
        case .AddAccount:
            addAccount()
        case .LurkerMode:
            lurkerMode()
        case .SwitchToUsername(let username):
            switchToUsername(username)
        case .Unimplemented:
            UIAlertView(title: "Unimplemented", message: nil, delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
}

extension AccountsFlowController : OAuthFlowControllerDelegate {
    func oauthFlowControllerDidCancel(oauthFlowController: OAuthFlowController) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
            }
        }
    }
    
    func oauthFlowController(oauthFlowController: OAuthFlowController, didCompleteWithResponse response: OAuthAuthorizeResponse) {
        addAccountFlowController.stopAnimated(true) { [weak self] in
            if let strongSelf = self {
                strongSelf.addAccountFlowController = nil
                strongSelf.dataController.reloadMenu()
            }
        }
    }
}

extension AccountsFlowController : AccountsDataControllerDelegate {
    public func accountsDataController(dataController: AccountsDataController, didLoadMenu menu: Menu<AccountMenuEvent>) {
        menu.eventHandler = handleAccountMenuEvent
        
        if accountsMenuViewController.isViewLoaded() {
            accountsMenuViewController.reloadMenu(menu)
        } else {
            accountsMenuViewController.menu = menu
        }
    }
}
