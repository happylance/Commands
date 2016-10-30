//
//  SshUtils.swift
//  Commands
//
//  Created by Liu Liang on 5/2/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import NMSSH
import Result

class SshUtils {
    static func executeSshCmd(_ command: String) -> Result<String, NSError> {
        let configFilePath = Bundle.main.path(forResource: "config", ofType: nil);
        guard let config = NMSSHConfig(fromFile:configFilePath) else {
            return .failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Failed to create NMSSHConfig"]))
        }
        
        guard let session = NMSSHSession(host:"ec2", configs:[config], withDefaultPort: 22, defaultUsername: "ubuntu") else {
            return .failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Failed to create NMSSHSession"]))
        }

        session.connect()
        if session.isConnected {
            let privateKey = Bundle.main.path(forResource: "ec2", ofType: "pem");
            session.authenticate(byPublicKey: nil, privateKey: privateKey, andPassword: nil)
            if session.isAuthorized {
                print("Authentication succeeded");
            } else {
                return .failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Authentication failed"]))
            }
        } else {
            return .failure(NSError(domain:"Commands", code: 102, userInfo: [NSLocalizedDescriptionKey : "Connection failed"]))
        }
        
        var error : NSError? = nil
        let response = session.channel.execute(command, error:&error, timeout:10) ?? ""
        if let error = error {
            print(error)
            return .failure(error)
        }
        
        session.disconnect()
        return .success(response)
    }
    
    static func executeSshCmdWithPassword(_ command: String, host: String, username: String, password: String) -> Result<String, NSError> {
        guard let session = NMSSHSession(host:host, andUsername:username) else {
            return .failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Failed to create NMSSHSession"]))
        }
        
        session.connect()
        if session.isConnected {
            session.authenticateByKeyboardInteractive({
                (request : String?) -> String? in
                return password
            })
            if (session.isAuthorized) {
                print("Authentication succeeded");
            } else {
                return .failure(NSError(domain:"Commands", code: 101, userInfo: [NSLocalizedDescriptionKey : "Authentication failed"]))
            }
        } else {
            return .failure(NSError(domain:"Commands", code: 102, userInfo: [NSLocalizedDescriptionKey : "Connection failed"]))
        }
        
        var error : NSError? = nil
        let logLevel = NMSSHLogger.shared().logLevel
        NMSSHLogger.shared().logLevel = .error
        let response = session.channel.execute(command, error:&error, timeout:10) ?? ""
        NMSSHLogger.shared().logLevel = logLevel
        if let error = error {
            print(error)
            return .failure(error)
        }
        
        session.disconnect()
        return .success(response)
    }

    
}
