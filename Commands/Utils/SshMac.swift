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

let hostToUnlockKey = "hostToUnlock"
let hostUsernameToUnlockKey = "hostUsernameToUnlock"
let hostPasswordToUnlockKey = "hostPasswordToUnlock"

class SshMac {
    
    static func macUnlock(canRequireInput: Bool) -> Result<String, NSError> {
        return macCommand(canRequireInput, cmd: "unlock")
    }
    
    static func macCommand(canRequireInput: Bool, cmd: String) -> Result<String, NSError> {
        let host = KeychainWrapper.stringForKey(hostToUnlockKey)
        let username = KeychainWrapper.stringForKey(hostUsernameToUnlockKey)
        let password = KeychainWrapper.stringForKey(hostPasswordToUnlockKey)
        if canRequireInput && (host == nil || username == nil || password == nil ||
            host?.characters.count == 0 || username?.characters.count == 0 || password?.characters.count == 0) {
            let alert = UIAlertController(title: nil, message: "Please input host name, username and password", preferredStyle: UIAlertControllerStyle.Alert)
            var hostField: UITextField?;
            var usernameField: UITextField?;
            var passwordField: UITextField?;
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
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
                
                KeychainWrapper.setString(host, forKey: hostToUnlockKey)
                KeychainWrapper.setString(username, forKey: hostUsernameToUnlockKey)
                KeychainWrapper.setString(password, forKey: hostPasswordToUnlockKey)
            }))
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter host:"
                hostField = textField
            })
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter username:"
                usernameField = textField
            })
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter password:"
                textField.secureTextEntry = true
                passwordField = textField
            })
            let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController
            if (rootController != nil) {
                rootController!.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        if host?.characters.count > 0 && username?.characters.count > 0 && password?.characters.count > 0 {
            let command = getDetailCommand(cmd, password: password!)
            let result = SshUtils.executeSshCmdWithPassword(command, host: host!, username: username!, password: password!)
            
            return result
        } else {
            if host == nil || host?.characters.count == 0 {
                return .Failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "Host is not set"]))
            }
            
            if username == nil || username?.characters.count == 0 {
                return .Failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "Username is not set"]))
            }
            
            return .Failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "Password is not set"]))
        }
    }
    
    static func getDetailCommand(cmd: String, password: String) -> String {
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
        let host = KeychainWrapper.stringForKey(hostToUnlockKey)
        
        KeychainWrapper.removeObjectForKey(hostToUnlockKey)
        KeychainWrapper.removeObjectForKey(hostUsernameToUnlockKey)
        KeychainWrapper.removeObjectForKey(hostPasswordToUnlockKey)
        
        if host == nil || host?.characters.count == 0 {
            return .Success("There's no host to forget.")
        } else {
            return .Success("Login info for \(host!) was removed.")
        }
    }
}