//
//  SshUtils.swift
//  Automation
//
//  Created by Liu Liang on 5/2/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import NMSSH

class SshUtils {
    static func executeSshCmd(command: String) -> String {
        let configFilePath = NSBundle.mainBundle().pathForResource("config", ofType: nil);
        let config = NMSSHConfig(fromFile:configFilePath)
        
        let session = NMSSHSession(host:"ec2", configs:[config], withDefaultPort: 22, defaultUsername: "ubuntu")
        session.connect()
        if session.connected {
            let privateKey = NSBundle.mainBundle().pathForResource("ec2", ofType: "pem");
            session.authenticateByPublicKey(nil, privateKey: privateKey, andPassword: nil)
            if (session.authorized) {
                print("Authentication succeeded");
            }
        }
        
        var error : NSError? = nil
        var response = session.channel.execute(command, error:&error, timeout:10)
        if let error = error {
            print(error)
            response = "\(response)\(error.description)"
        }
        
        print(response)
        session.disconnect()
        return response
    }
    
}