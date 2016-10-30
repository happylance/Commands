//
//  SshUnlock.swift
//  Commands
//
//  Created by Liu Liang on 5/8/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import Result
import SwiftKeychainWrapper
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let hostToUnlockKey = "hostToUnlock"
let hostUsernameToUnlockKey = "hostUsernameToUnlock"
let hostPasswordToUnlockKey = "hostPasswordToUnlock"

class SshMac {
    
    static func macUnlock(_ canRequireInput: Bool) -> Result<String, NSError> {
        return macCommand(canRequireInput, cmd: "unlock")
    }
    
    static func macCommand(_ canRequireInput: Bool, cmd: String) -> Result<String, NSError> {
        let host = KeychainWrapper.standard.string(forKey: hostToUnlockKey)
        let username = KeychainWrapper.standard.string(forKey: hostUsernameToUnlockKey)
        let password = KeychainWrapper.standard.string(forKey: hostPasswordToUnlockKey)
        if canRequireInput && (host == nil || username == nil || password == nil ||
            host?.characters.count == 0 || username?.characters.count == 0 || password?.characters.count == 0) {
            DispatchQueue.main.async(execute: { 
                requireLoginInfo()
            })
        }
        
        if host?.characters.count > 0 && username?.characters.count > 0 && password?.characters.count > 0 {
            let command = getDetailCommand(cmd, password: password!)
            let result = SshUtils.executeSshCmdWithPassword(command, host: host!, username: username!, password: password!)
            
            return result
        } else {
            if host == nil || host?.characters.count == 0 {
                return .failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "Host is not set"]))
            }
            
            if username == nil || username?.characters.count == 0 {
                return .failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "Username is not set"]))
            }
            
            return .failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "Password is not set"]))
        }
    }
    
    static func getDetailCommand(_ cmd: String, password: String) -> String {
        switch cmd {
        case "unlock":
            return "caffeinate  -u -t 1;" +  // Wake up the screen.
                "d=$(/usr/bin/python -c 'import Quartz; print Quartz.CGSessionCopyCurrentDictionary()');" +
                "echo $d | grep -q 'OnConsoleKey = 0' && { echo 'Sorry that you have unlock manually.'; echo $d; return; };" +
                "echo $d | grep -q 'ScreenIsLocked = 1' || { echo 'Mac is already unlocked.'; return; }; " +
                "osascript -e 'tell application \"System Events\"' -e 'keystroke \"\(password)\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'"
        case "sleep":
            return "osascript -e 'tell application \"Finder\" to sleep'"
        default:
            return cmd;
        }
    }
    
    static func macForget() -> Result<String, NSError> {
        let host = KeychainWrapper.standard.string(forKey: hostToUnlockKey)
        
        KeychainWrapper.standard.removeObject(forKey: hostToUnlockKey)
        KeychainWrapper.standard.removeObject(forKey: hostUsernameToUnlockKey)
        KeychainWrapper.standard.removeObject(forKey: hostPasswordToUnlockKey)
        
        if host == nil || host?.characters.count == 0 {
            return .success("There's no host to forget.")
        } else {
            return .success("Login info for \(host!) was removed.")
        }
    }
    
    static func requireLoginInfo() {
        let alert = UIAlertController(title: nil, message: "Please input host name, username and password", preferredStyle: UIAlertControllerStyle.alert)
        var hostField: UITextField?;
        var usernameField: UITextField?;
        var passwordField: UITextField?;
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action)->() in
            let host = hostField?.text ?? ""
            if host.isEmpty {
                return
            }
            
            let username = usernameField?.text ?? ""
            if username.isEmpty {
                return
            }
            
            let password = passwordField?.text ?? ""
            if password.isEmpty {
                return
            }
            
            KeychainWrapper.standard.set(host, forKey: hostToUnlockKey)
            KeychainWrapper.standard.set(username, forKey: hostUsernameToUnlockKey)
            KeychainWrapper.standard.set(password, forKey: hostPasswordToUnlockKey)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter host:"
            hostField = textField
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter username:"
            usernameField = textField
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter password:"
            textField.isSecureTextEntry = true
            passwordField = textField
        })
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        if (rootController != nil) {
            rootController!.present(alert, animated: true, completion: nil)
        }
    }
}
