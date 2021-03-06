//
//  SelectSoundFilterViewController.swift
//  Pitch Perfect
//
//  Created by Josh Petite on 5/11/15.
//  Copyright (c) 2015 Josh Petite. All rights reserved.
//

import UIKit
import AVFoundation

class SelectSoundFilterViewController: UIViewController {
    var receivedAudio: RecordedAudio!
    var engine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine = AVAudioEngine()
        
        if (receivedAudio != nil) {
            audioFile = AVAudioFile(forReading: receivedAudio.getUrl(), error: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopEngine()
    }
    
    @IBAction func playSlowAudio() {
        executeRatePitchAwarePlayback(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        executeRatePitchAwarePlayback(2.0)
    }
    @IBAction func playChipmunkFilteredAudio(sender: UIButton) {
        executeRatePitchAwarePlayback(1.0, pitch: 1200.0)
    }
    
    @IBAction func playVaderFilteredAudio(sender: UIButton) {
        executeRatePitchAwarePlayback(1.0, pitch: -500.0)
    }
    
    @IBAction func playReverbFilteredAudio(sender: UIButton) {
        executeReverbPlayback()
    }
    
    @IBAction func playDistortionFilteredAudio(sender: UIButton) {
        executeDistoredPlayback()
    }
    
    func stopEngine() {
        engine.stop()
        engine.reset()
    }
    
    @IBAction func stopPlayback(sender: UIButton) {
        stopEngine()
    }
    
    func executeDistoredPlayback() {
        stopEngine()
        
        // create and attach the audio player node
        var audioPlayer = AVAudioPlayerNode()
        audioPlayer.volume = 1.0;
        engine.attachNode(audioPlayer)
        
        // create and attach the distortion node
        var distortion = AVAudioUnitDistortion()
        distortion.wetDryMix = 50
        distortion.preGain = 0
        engine.attachNode(distortion)
        
        // connect nodes in engine
        engine.connect(audioPlayer, to: distortion, format: nil)
        engine.connect(distortion, to: engine.outputNode, format: nil)
        
        audioPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        engine.startAndReturnError(nil)
        audioPlayer.play()
    }
    
    func executeReverbPlayback() {
        stopEngine()
        
        // create and attach the audio player node
        var audioPlayer = AVAudioPlayerNode()
        audioPlayer.volume = 1.0;
        engine.attachNode(audioPlayer)
        
        // create and attach the reverb node
        var reverb = AVAudioUnitReverb()
        reverb.wetDryMix = 50
        engine.attachNode(reverb)
        
        // connect nodes in engine
        engine.connect(audioPlayer, to: reverb, format: nil)
        engine.connect(reverb, to: engine.outputNode, format: nil)
        
        audioPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        engine.startAndReturnError(nil)
        audioPlayer.play()
    }
    
    func executeRatePitchAwarePlayback(rate: Float, pitch: Float = 1.0) {
        stopEngine()
        
        // create and attach the audio player node
        var audioPlayer = AVAudioPlayerNode()
        audioPlayer.volume = 1.0;
        engine.attachNode(audioPlayer)
        
        // create and attach unit time pitch node
        var unitTimePitch = AVAudioUnitTimePitch()
        unitTimePitch.rate = rate
        unitTimePitch.pitch = pitch
        engine.attachNode(unitTimePitch)
        
        // connect nodes in engine
        engine.connect(audioPlayer, to: unitTimePitch, format: nil)
        engine.connect(unitTimePitch, to: engine.outputNode, format: nil)
        
        audioPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        engine.startAndReturnError(nil)
        audioPlayer.play()
    }
}
