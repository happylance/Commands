//
//  Utils.swift
//  Commands
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import AVFoundation
import Result

class Utils {
    static func sayCN(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        synthesizer.speak(utterance)
    }
    
    static func getTime() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "h:mm a"
        let time = dateFormat.string(from: Date())
        return time
    }
    
    static func executeCmd(_ cmd: String) -> Result<String, NSError> {
        var command = cmd
        let localPrefix = "local "
        if command.hasPrefix(localPrefix) {
            command.removeSubrange(localPrefix.characters.startIndex..<localPrefix.characters.endIndex)
            return executeLocalCmd(command)
        }
        
        let macPrefix = "mac "
        if command.lowercased().hasPrefix(macPrefix) {
            if command.lowercased().contains("mac unlock") {
                return SshMac.macUnlock(true)
            }
            
            if command.lowercased().contains("mac forget") {
                return SshMac.macForget()
            }
            
            command.removeSubrange(macPrefix.characters.startIndex..<macPrefix.characters.endIndex)
            return SshMac.macCommand(true, cmd: command)
        }
        
        return SshUtils.executeSshCmd(command)
    }
    
    static func executeLocalCmd(_ cmd: String) -> Result<String, NSError> {
        var command = cmd
        let sayPrefix = "say "
        if command.hasPrefix(sayPrefix) {
            command.removeSubrange(sayPrefix.characters.startIndex..<sayPrefix.characters.endIndex)
            
            if command == "time" {
                command = "亮哥，现在时间\(Utils.getTime())"
            }
            
            Utils.sayCN(command)
            return .success("")
        } else {
            return .failure(NSError(domain:"Commands", code: 121, userInfo: [NSLocalizedDescriptionKey : "This command is not supported."]))
        }
    }
    
    static func showAlertWithMessage(_ title: String, msg: String, controller: UIViewController, completion: (() -> Void)? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
        controller.present(alert, animated: true, completion: completion)
    }
}
