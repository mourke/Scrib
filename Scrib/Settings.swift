//
//  Settings.swift
//  Scrib
//
//  Copyright © 2020 Mark Bourke.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

import Foundation
import LastFMKit.LFMUser
import OSLog

class Settings: NSObject {
    
    static let manager = Settings()
    
    /** `true` if application should automatically start when the computer starts. */
    @objc dynamic private(set) var startOnLogin: Bool
    
    /** `true` if application should scrobble now playing tracks to Last.fm */
    @objc dynamic private(set) var scrobbling: Bool
    
    /** `true` if application should automatically check for updates. */
    @objc dynamic private(set) var automaticUpdates: Bool
    
    /** The percentage of the song that has to play before a scrobble is registered. */
    @objc dynamic private(set) var scrobblePercentage: Int
    
    /** Because there is no way to tell when a song actually ends, set this to `true` if you want the song to be scrobbled when the time period has elapsed and a `Pause` or `Skip` notification have not been recieved. */
    @objc dynamic private(set) var scrobbleAfterSongDurationExpires: Bool
    
    /** `true` will send notifications every time a song is played to show the scrobbling feature is working. */
    @objc dynamic private(set) var enableNotifications: Bool
    
    /** The currently signed in user. */
    @objc dynamic private(set) var user: User?
    
    var isSignedIn: Bool {
        return user != nil
    }
    
    private lazy var writeWorkItem = DispatchWorkItem { [weak self] in
        self?.writeToDisk()
    }
    
    override init() {
        startOnLogin = UserDefaults.standard.bool(forKey: #keyPath(Settings.startOnLogin))
        scrobbling = UserDefaults.standard.bool(forKey: #keyPath(Settings.scrobbling))
        automaticUpdates = UserDefaults.standard.bool(forKey: #keyPath(Settings.automaticUpdates))
        scrobblePercentage = UserDefaults.standard.integer(forKey: #keyPath(Settings.scrobblePercentage))
        scrobbleAfterSongDurationExpires = UserDefaults.standard.bool(forKey: #keyPath(Settings.scrobbleAfterSongDurationExpires))
        enableNotifications = UserDefaults.standard.bool(forKey: #keyPath(Settings.enableNotifications))
        if let userData = UserDefaults.standard.data(forKey: #keyPath(Settings.user)),
            let user = try? NSKeyedUnarchiver.unarchivedObject(ofClass: User.self, from: userData) {
            self.user = user
        } else {
            user = nil
        }
        
        super.init()
    }
    
    func changeValue<Value>(_ key: ReferenceWritableKeyPath<Settings, Value>, to newValue: Value) {
        writeWorkItem.cancel()
        
        self[keyPath: key] = newValue
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: writeWorkItem)
    }
    
    private func writeToDisk() {
        UserDefaults.standard.set(startOnLogin, forKey: #keyPath(Settings.startOnLogin))
        UserDefaults.standard.set(scrobbling, forKey: #keyPath(Settings.scrobbling))
        UserDefaults.standard.set(automaticUpdates, forKey: #keyPath(Settings.automaticUpdates))
        UserDefaults.standard.set(scrobblePercentage, forKey: #keyPath(Settings.scrobblePercentage))
        UserDefaults.standard.set(enableNotifications, forKey: #keyPath(Settings.enableNotifications))
        
        do {
            if let user = user {
                let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: true)
                UserDefaults.standard.set(data, forKey: #keyPath(Settings.user))
            }
        } catch {
            os_log(.error, "Failed to write user information: %s", error.localizedDescription)
        }
    }
}
