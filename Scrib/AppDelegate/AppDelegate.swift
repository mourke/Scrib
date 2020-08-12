//
//  AppDelegate.swift
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

import Cocoa
import SwiftUI
import func ServiceManagement.SMLoginItemSetEnabled
import LastFMKit

class AppDelegate: NSObject, NSApplicationDelegate {

    var activeWindow: NSWindow? {
        didSet {
            if let window = activeWindow {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            } else {
                oldValue?.orderOut(nil)
                NSApp.hide(nil)
                NSApp.unhideWithoutActivation()
            }
        }
    }
    
    @objc dynamic var currentlyPlayingTrack: ScrobbleTrack?
    
    var onboardingPopover: NSPopover!
    
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var currentScrobbleMenuItem: NSMenuItem!
    var favouriteMenuItem: NSMenuItem!
    var tagMenuItem: NSMenuItem!
    var profileMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LastFMKit.Auth.shared().apiKey = "bc15dd6972bc0f7c952273b34d253a6a"
        LastFMKit.Auth.shared().apiSecret = "d46ca773c61a3907c0b19c777c5bcf20"
        
        configureStatusItem()
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(nowPlayingChanged), name: NSNotification.Name(rawValue: "com.apple.Music.playerInfo"), object: nil)
        
        SMLoginItemSetEnabled("com.mourke.scrib-launcher" as CFString, true)
    }
    
    @objc func nowPlayingChanged(_ aNotification: Notification) {
        guard let trackInfo = aNotification.userInfo,
            let song = trackInfo["Name"] as? String,
            let artist = trackInfo["Artist"] as? String,
            let playerState = trackInfo["Player State"] as? String
        else {
            return
        }
        
        if playerState == "Playing" {
            let album = trackInfo["Album"] as? String
            let positionInAlbum = trackInfo["Track Number"] as? Int
            let albumArtist = trackInfo["Album Artist"] as? String
            let totalDurationMilliseconds = trackInfo["Total Time"] as? Int
            let duration = (totalDurationMilliseconds != nil) ? totalDurationMilliseconds!/1000 : nil
            
//            ScrobbleTrack.init(name: song,
//                               artistName: artist,
//                               albumName: album,
//                               albumArtist: albumArtist,
//                               positionInAlbum: positionInAlbum ?? 0,
//                               duration: duration,
//                               timestamp: Date(),
//                               chosenByUser: true)
            
            
//            TrackProvider.updateNowPlaying(track: song,
//                                           by: artist,
//                                           on: album,
//                                           position: positionInAlbum,
//                                           albumArtist: albumArtist,
//                                           duration: duration,
//                                           mbid: nil,
//                                           callback: nil)
            
            currentScrobbleMenuItem.title = "\(artist) - \(song)"
            favouriteMenuItem.isEnabled = true
            tagMenuItem.isEnabled = true
        } else {
            currentScrobbleMenuItem.title = "Nothing playing"
            favouriteMenuItem.isEnabled = false
            tagMenuItem.isEnabled = false
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

