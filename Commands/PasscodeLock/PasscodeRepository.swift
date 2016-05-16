//
//  PasscodeRepository.swift
//  Commands
//
//  Created by Liu Liang on 5/7/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import PasscodeLock
import SwiftKeychainWrapper

class PasscodeRepository: PasscodeRepositoryType {
    
    private let passcodeKey = "commands.lock.passcode"
    
    var hasPasscode: Bool {
        return passcode != nil
    }
    
    var passcode: [String]? {
        return KeychainWrapper.stringForKey(passcodeKey)?.characters.map{String($0)}
    }
    
    func savePasscode(passcode: [String]) {
        let passcodeString = passcode.reduce("") {"\($0)\($1)"}
        KeychainWrapper.setString(passcodeString, forKey: passcodeKey)
    }
    
    func deletePasscode() {
        KeychainWrapper.removeObjectForKey(passcodeKey)
    }
}
