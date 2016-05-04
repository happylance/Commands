//
//  Utils.swift
//  Automation
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
            return .Success(executeLocalCmd(command))
        }
        return SshUtils.executeSshCmd(command)
    }
    
    static func executeLocalCmd(cmd: String) -> String {
        var command = cmd
        let sayPrefix = "say "
        if command.hasPrefix(sayPrefix) {
            command.removeRange(sayPrefix.startIndex ..< sayPrefix.endIndex)
            
            if command == "time" {
                command = "亮哥，现在时间\(Utils.getTime())"
            }
            
            Utils.sayCN(command)
        }
        return ""
    }
    
}