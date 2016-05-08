//
//  SshUtils.swift
//  Automation
//
//  Created by Liu Liang on 5/2/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import NMSSH
import Result

class SshUtils {
    static func executeSshCmd(command: String) -> Result<String, NSError> {
        let configFilePath = NSBundle.mainBundle().pathForResource("config", ofType: nil);
        let config = NMSSHConfig(fromFile:configFilePath)
        
        let session = NMSSHSession(host:"ec2", configs:[config], withDefaultPort: 22, defaultUsername: "ubuntu")
        session.connect()
        if session.connected {
            let privateKey = NSBundle.mainBundle().pathForResource("ec2", ofType: "pem");
            session.authenticateByPublicKey(nil, privateKey: privateKey, andPassword: nil)
            if (session.authorized) {
                print("Authentication succeeded");
            } else {
                return .Failure(NSError(domain:"Automation", code: 101, userInfo: [NSLocalizedDescriptionKey : "Authentication failed"]))
            }
        } else {
            return .Failure(NSError(domain:"Automation", code: 102, userInfo: [NSLocalizedDescriptionKey : "Connection failed"]))
        }
        
        var error : NSError? = nil
        let response = session.channel.execute(command, error:&error, timeout:10)
        if let error = error {
            print(error)
            return .Failure(error)
        }
        
        print(response)
        session.disconnect()
        return .Success(response)
    }
    
}