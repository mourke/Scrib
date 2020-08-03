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
    
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var currentScrobbleMenuItem: NSMenuItem!
    var favouriteMenuItem: NSMenuItem!
    var tagMenuItem: NSMenuItem!
    var profileMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        addStatusItem()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(nowPlayingChanged), name: NSNotification.Name(rawValue: "com.apple.Music.playerInfo"), object: nil)
        
        SMLoginItemSetEnabled("com.mourke.scrib-launcher" as CFString, true)
        
        if !Settings.manager.isSignedIn {
            showOnboardingView()
        }
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
            
            TrackProvider.updateNowPlaying(track: song,
                                           by: artist,
                                           on: album,
                                           position: positionInAlbum as NSNumber?,
                                           albumArtist: albumArtist,
                                           duration: duration as NSNumber?,
                                           mbid: nil,
                                           callback: nil)
            currentScrobbleMenuItem.title = "\(artist) - \(song)"
            favouriteMenuItem.isEnabled = true
            tagMenuItem.isEnabled = true
        } else {
            currentScrobbleMenuItem.title = "Nothing playing"
            favouriteMenuItem.isEnabled = false
            tagMenuItem.isEnabled = false
        }
    }
    
    @objc func showOnboardingView() {
        let onboardingView = OnboardingView()
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: CGSize(width: 300, height: 400)),
                              styleMask: [.titled, .fullSizeContentView, .closable],
                                  backing: .buffered, defer: false)
        window.contentView = NSHostingView(rootView: onboardingView)
        window.center()
        activeWindow = window
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

