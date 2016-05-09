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

class SshUnlock {
    static func macUnlock(canRequireInput: Bool) -> Result<String, NSError> {
        let host = KeychainWrapper.stringForKey("hostToUnlock")
        let username = KeychainWrapper.stringForKey("hostUsernameToUnlock")
        let password = KeychainWrapper.stringForKey("hostPasswordToUnlock")
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
                
                KeychainWrapper.setString(host, forKey: "hostToUnlock")
                KeychainWrapper.setString(username, forKey: "hostUsernameToUnlock")
                KeychainWrapper.setString(password, forKey: "hostPasswordToUnlock")
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
            let command = "/usr/bin/python -c 'import Quartz; print Quartz.CGSessionCopyCurrentDictionary();'" +
                "| grep -q 'ScreenIsLocked = 1' || { echo 'Mac is already unlocked.'; return; }; " +
                "osascript -e 'tell application \"System Events\"' -e 'keystroke \"\(password!)\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'"
            let result = SshUtils.executeSshCmdWithPassword(command, host: host!, username: username!, password: password!)
            
            return result
        } else {
            if host?.characters.count == 0 {
                return .Failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "Host is empty"]))
            }
            
            if username?.characters.count == 0 {
                return .Failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "username is empty"]))
            }
            
            return .Failure(NSError(domain:"Commands", code: 111, userInfo: [NSLocalizedDescriptionKey : "password is empty"]))
        }
    }
}