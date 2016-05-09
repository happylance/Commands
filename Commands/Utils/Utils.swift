//
//  Utils.swift
//  Commands
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import Foundation
import AVFoundation
import Result

class Utils {
    static func sayCN(text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        synthesizer.speakUtterance(utterance)
    }
    
    static func getTime() -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "h:mm a"
        let time = dateFormat.stringFromDate(NSDate())
        return time
    }
    
    static func executeCmd(cmd: String) -> Result<String, NSError> {
        var command = cmd
        let localPrefix = "local "
        if command.hasPrefix(localPrefix) {
            command.removeRange(localPrefix.startIndex ..< localPrefix.endIndex)
            return executeLocalCmd(command)
        }
        
        if command.lowercaseString.containsString("mac unlock") {
            return SshUnlock.macUnlock(true)
        }
        
        if command.lowercaseString.containsString("mac forget") {
            return SshUnlock.macForget()
        }
        
        return SshUtils.executeSshCmd(command)
    }
    
    static func executeLocalCmd(cmd: String) -> Result<String, NSError> {
        var command = cmd
        let sayPrefix = "say "
        if command.hasPrefix(sayPrefix) {
            command.removeRange(sayPrefix.startIndex ..< sayPrefix.endIndex)
            
            if command == "time" {
                command = "亮哥，现在时间\(Utils.getTime())"
            }
            
            Utils.sayCN(command)
            return .Success("")
        } else {
            return .Failure(NSError(domain:"Commands", code: 121, userInfo: [NSLocalizedDescriptionKey : "This command is not supported."]))
        }
    }
}
