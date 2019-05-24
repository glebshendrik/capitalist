//
//  SoundsManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 15/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import AudioToolbox

class SoundsManager : SoundsManagerProtocol {
    enum Keys : String {
        case soundsEnabled
    }
    
    struct Sound {
        enum Name : String {
            case movement = "coins-movement"
            case drop = "coin-roll-drop"
        }
        
        enum Extension : String {
            case caf
            case aif
            case wav
        }
    }
    
    private var sounds: [String: SystemSoundID] = [String: SystemSoundID]()
    
    var soundsEnabled: Bool {
        return UserDefaults.standard.bool(forKey: Keys.soundsEnabled.rawValue)
    }
    
    func setSounds(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.soundsEnabled.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func playTransactionStartedSound() {
        play(sound: .drop, format: .wav)
    }
    
    func playTransactionCompletedSound() {
        play(sound: .movement, format: .wav)
    }
    
    private func play(sound name: Sound.Name, format: Sound.Extension) {
        guard soundsEnabled else { return }
        
        let soundName = name.rawValue
        let soundExtension = format.rawValue
        
        guard let soundId = loadSound(by: soundName, format: soundExtension) else { return }
        
        AudioServicesPlaySystemSound(soundId)
    }
    
    private func loadSound(by name: String, format: String) -> SystemSoundID? {
        if let soundId = sounds[name] {
            return soundId
        }
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: format) as CFURL? else { return nil }
        
        var soundId: SystemSoundID = 0
        let osStatus: OSStatus = AudioServicesCreateSystemSoundID(soundURL, &soundId)
        
        guard osStatus == kAudioServicesNoError else { return nil }
        
        sounds[name] = (soundId)
        
        return soundId
    }
    
}
