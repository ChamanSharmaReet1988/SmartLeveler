//
//  VoiceRecognization.swift
//  smartleveler
//
//  Created by com on 08/10/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

protocol VoiceRecognizationDelegate {
    func getText(text: String)
    func speechRecognizerAvailability(isEnabled: Bool)
}

class VoiceRecognization: NSObject, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    var timer = Timer()
    var howManyTimeAdded : Int = 0
    
    var voiceRecognizationDelegate: VoiceRecognizationDelegate?
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    var audioEngine = AVAudioEngine()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var speechSynthesizer = AVSpeechSynthesizer()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    private static var voiceRecognization: VoiceRecognization = {
        let voiceRecognization = VoiceRecognization()
        return voiceRecognization
    }()
    class func shared() -> VoiceRecognization {
        return voiceRecognization
    }
    var voiceRecognizationIsEnabled: Bool = false
    
    override init()
    {
        super.init()
        speechRecognizer.delegate = self
        speechSynthesizer.delegate = self
        speechRecognizer = SFSpeechRecognizer(locale: NSLocale(localeIdentifier: "en-US") as Locale)!
        SFSpeechRecognizer.requestAuthorization { (status) in
            if status == .denied
            {
                self.voiceRecognizationIsEnabled = false
            }
            if status == .authorized
            {
                self.voiceRecognizationIsEnabled = true
            }
            if status == .restricted
            {
                self.voiceRecognizationIsEnabled = false
            }
            if status == .notDetermined
            {
                self.voiceRecognizationIsEnabled = false
            }
            
            if let _ = self.voiceRecognizationDelegate
            {
                self.voiceRecognizationDelegate?.speechRecognizerAvailability(isEnabled: self.voiceRecognizationIsEnabled )
            }
        }
    }
    
    func stopRecording()
    {
        if audioEngine.isRunning
        {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("savereading"), object: nil)
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
        }
    }
    
    var strSpeechText : String! = ""
    var strResult : String! = ""
    
    func startRecording()
    {
        if recognitionTask != nil
        {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let avAudioSession = AVAudioSession.sharedInstance()
        try? avAudioSession.setMode(AVAudioSessionModeMeasurement)
        try? avAudioSession.setActive(true)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        let inputNode: AVAudioInputNode? = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!, resultHandler: {(_ result: SFSpeechRecognitionResult?, _ error: Error?) -> Void in
            var isFinal: Bool = false
           
            if result != nil
            {
                if let _ = self.voiceRecognizationDelegate
                {
                    self.voiceRecognizationDelegate?.getText(text: (result?.bestTranscription.formattedString)!)
                    
                    let noOfTimes : Int! = result?.bestTranscription.formattedString.countInstances(of: "save reading")
                    
                    
                    if (result?.bestTranscription.formattedString.containsIgnoringCase(find: "save reading"))! && self.howManyTimeAdded < noOfTimes!
                    {
                        print("CONTAINS")
                       
                        self.howManyTimeAdded = self.howManyTimeAdded + 1
                        
                         NotificationCenter.default.post(name: Notification.Name("savereading"), object: nil, userInfo: nil)

                    }
                }
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal
            {
                inputNode?.removeTap(onBus: 0)
                self.audioEngine.stop()
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.voiceRecognizationIsEnabled = true
               
                NotificationCenter.default.post(name: Notification.Name("speechstopped"), object: nil, userInfo: nil)
                
            }
        })
        
        let recordingFormat: AVAudioFormat? = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: {(_ buffer: AVAudioPCMBuffer, _ when: AVAudioTime) -> Void in
            self.recognitionRequest?.append(buffer)
        })
        audioEngine.prepare()
        try? audioEngine.start()
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available
        {
            voiceRecognizationIsEnabled = true
        }
        else
        {
            voiceRecognizationIsEnabled = false
        }
    }
    
}

extension String
{
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
        func countInstances(of stringToFind: String) -> Int {
            assert(!stringToFind.isEmpty)
            var count = 0
            var searchRange: Range<String.Index>?
            while let foundRange = range(of: stringToFind, options:.caseInsensitive, range: searchRange) {
                count += 1
                searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
            }
            return count
        }
}
