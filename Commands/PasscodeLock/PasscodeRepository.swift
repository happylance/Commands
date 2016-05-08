//
//  PasscodeRepository.swift
//  Commands
//
//  Created by Liu Liang on 5/7/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import PasscodeLock

class PasscodeRepository: PasscodeRepositoryType {
    
    private let passcodeKey = "automation.lock.passcode"
    
    private lazy var passcodeString: String = {
        let passcodeFilePath = NSBundle.mainBundle().pathForResource(".passcode", ofType: nil);

        var passcode : String = ""
        do
        {
            passcode = try String(contentsOfFile: passcodeFilePath!)
        }
        catch
        {
            passcode = ""
        }
    
        return passcode
    }()
    
    var hasPasscode: Bool {
        return true
    }
    
    var passcode: [String]? {
        return passcodeString.characters.map{String($0)}
    }
    
    func savePasscode(passcode: [String]) {
    }
    
    func deletePasscode() {
    }
}
