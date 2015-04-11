//
//  MidnightBaconTests.swift
//  MidnightBaconTests
//
//  Created by Justin Kolb on 10/1/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import UIKit
import XCTest

class MidnightBaconTests: XCTestCase {
    func testKeychainGenericPassword() {
        let keychain = Keychain()
        
        var genericPassword = Keychain.GenericPassword()
        let testData = "testData".dataUsingEncoding(NSUTF8StringEncoding)!
        genericPassword.service = "testService"
        genericPassword.account = "testAccount"
        
        let addStatus = keychain.addData(genericPassword, data: testData)
        println(addStatus.message)
        XCTAssertEqual(Success, addStatus, "Failed to add item")
        
        let duplicateStatus = keychain.addData(genericPassword, data: testData)
        println(duplicateStatus.message)
        XCTAssertEqual(DuplicateItem, duplicateStatus, "Should not allow duplicates")
        
        let lookupResult = keychain.lookupData(genericPassword)
        
        switch lookupResult {
        case .Success(let dataClosure):
            let data = dataClosure.unwrap
            let expected = "testData".dataUsingEncoding(NSUTF8StringEncoding)!
            XCTAssertEqual(expected, data[0], "Unexpected data found")
        case .Failure(let keychainError):
            println(keychainError)
            XCTAssertTrue(false, "Failed to lookup item")
        }
        
        let deleteStatus = keychain.delete(genericPassword)
        println(deleteStatus.message)
        XCTAssertEqual(Success, deleteStatus, "Failed to delete item")
        
        let lookupResultAfter = keychain.lookupData(genericPassword)
        
        switch lookupResultAfter {
        case .Success(let dataClosure):
            XCTAssertTrue(false, "Should not have found item")
        case .Failure(let error):
            println(error)
            if let keychainError = error as? KeychainError {
                XCTAssertEqual(ItemNotFound, keychainError.status, "Failed to delete item")
            } else {
                XCTAssertTrue(false, "Unexpected error")
            }
        }
    }

    func testFindGenericPassword() {
        let keychain = Keychain()
        
        var genericPasswordA = Keychain.GenericPassword()
        let testDataA = "testDataA".dataUsingEncoding(NSUTF8StringEncoding)!
        genericPasswordA.service = "testService"
        genericPasswordA.account = "testAccountA"
        
        var genericPasswordB = Keychain.GenericPassword()
        let testDataB = "testDataB".dataUsingEncoding(NSUTF8StringEncoding)!
        genericPasswordB.service = "testService"
        genericPasswordB.account = "testAccountB"
        
        keychain.addData(genericPasswordA, data: testDataA)
        keychain.addData(genericPasswordB, data: testDataA)
        
        let result = keychain.findGenericPassword(service: "testService")
        
        switch result {
        case .Success(let valuesClosure):
            let array = valuesClosure.unwrap
            for item in array {
                println(item.account)
            }
            XCTAssertEqual(2, array.count, "Failed")
        case .Failure(let error):
            println(error)
            XCTAssertTrue(false, "Unexpected error")
        }
        
        keychain.delete(genericPasswordA)
        keychain.delete(genericPasswordB)
    }
    
    func testFindNoGenericPassword() {
        let keychain = Keychain()
        let result = keychain.findGenericPassword(service: "testService")
        
        switch result {
        case .Success(let valuesClosure):
            let array = valuesClosure.unwrap
            for item in array {
                println(item.account)
            }
            XCTAssertEqual(0, array.count, "Failed")
        case .Failure(let error):
            println(error)
            XCTAssertTrue(false, "Unexpected error")
        }
    }
    
    func testKeychainInternetPassword() {
        let keychain = Keychain()
        
        var internetPassword = Keychain.InternetPassword()
        let testData = "testData".dataUsingEncoding(NSUTF8StringEncoding)!
        internetPassword.server = "testServer"
        internetPassword.account = "testAccount"
        
        let addStatus = keychain.addData(internetPassword, data: testData)
        println(addStatus.message)
        XCTAssertEqual(Success, addStatus, "Failed to add item")
        
        let duplicateStatus = keychain.addData(internetPassword, data: testData)
        println(duplicateStatus.message)
        XCTAssertEqual(DuplicateItem, duplicateStatus, "Should not allow duplicates")
        
        let lookupResult = keychain.lookupData(internetPassword)
        
        switch lookupResult {
        case .Success(let dataClosure):
            let data = dataClosure.unwrap
            let expected = "testData".dataUsingEncoding(NSUTF8StringEncoding)!
            XCTAssertEqual(expected, data[0], "Unexpected data found")
        case .Failure(let keychainError):
            println(keychainError)
            XCTAssertTrue(false, "Failed to lookup item")
        }
        
        let deleteStatus = keychain.delete(internetPassword)
        println(deleteStatus.message)
        XCTAssertEqual(Success, deleteStatus, "Failed to delete item")
        
        let lookupResultAfter = keychain.lookupData(internetPassword)
        
        switch lookupResultAfter {
        case .Success(let dataClosure):
            XCTAssertTrue(false, "Should not have found item")
        case .Failure(let error):
            println(error)
            if let keychainError = error as? KeychainError {
                XCTAssertEqual(ItemNotFound, keychainError.status, "Failed to delete item")
            } else {
                XCTAssertTrue(false, "Unexpected error")
            }
        }
    }
}
