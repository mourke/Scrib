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
import ScriptingBridge

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var onboardingPopover: NSPopover!
    
    var settingsWindow: NSWindow?
    var tagWindow: NSWindow?
    var favouriteWindow: NSWindow?
    
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var currentScrobbleMenuItem: NSMenuItem!
    var favouriteMenuItem: NSMenuItem!
    var tagMenuItem: NSMenuItem!
    var profileMenuItem: NSMenuItem!
    
    let musicApplication: MusicApplication = MusicApplicationObject()
    var isCurrentTrackLoved: Bool? = nil {
        didSet {
            guard oldValue != isCurrentTrackLoved else { return }
            
            let currentTrackLoved = isCurrentTrackLoved ?? false
            favouriteMenuItem.title = currentTrackLoved ? "Unfavourite" : "Favourite"
        }
    }
    
    var signedInObservation: NSKeyValueObservation!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = Updater.shared // initialise library
    
        LastFMKit.Auth.shared.apiKey = "bc15dd6972bc0f7c952273b34d253a6a"
        LastFMKit.Auth.shared.apiSecret = "d46ca773c61a3907c0b19c777c5bcf20"
        
        configureStatusItem()
        nowPlayingChanged() // update initial status
        
        signedInObservation = Settings.manager.observe(\.user, options: [.new, .initial]) { [weak self] (settings, change) in
            
            self?.profileMenuItem.isEnabled = settings.isSignedIn
            self?.updateActionMenuItemsEnabled()
        }
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(nowPlayingChanged), name: .MusicPlayerInfo, object: nil)
        
        SMLoginItemSetEnabled("com.mourke.scrib-launcher" as CFString, true)
    }
    
    @objc func nowPlayingChanged() {
        let isPlaying = musicApplication.playerState == .playing
        
        
        #warning("This method isn't called when the player is paused i don't think")

        if isPlaying {
            let currentTrack = musicApplication.currentTrack!
            let song = currentTrack.name!
            let artist = currentTrack.artist!
            
            TrackProvider.updateNowPlaying(track: song,
                                           by: artist,
                                           on: currentTrack.album,
                                           position: currentTrack.trackNumber,
                                           albumArtist: currentTrack.albumArtist,
                                           duration: currentTrack.duration).resume()
            isCurrentTrackLoved = false
            var title = "\(song)\n\(artist)"
            
            if let album = currentTrack.album {
                title += " - \(album)"
            }
            
            currentScrobbleMenuItem.attributedTitle = NSAttributedString(string: title)
        } else {
            isCurrentTrackLoved = nil
            currentScrobbleMenuItem.title = "Nothing playing"
        }

        updateActionMenuItemsEnabled()
    }
    
    func updateActionMenuItemsEnabled() {
        guard Settings.manager.isSignedIn else {
            favouriteMenuItem.isEnabled = false
            tagMenuItem.isEnabled = false
            return
        }
        
        let isPlaying = musicApplication.playerState == .playing
        
        favouriteMenuItem.isEnabled = isPlaying ? true : false
        tagMenuItem.isEnabled = isPlaying ? true : false
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func showWindow(_ window: NSWindow) {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true) // activate if not done already
    }
    
    func hideIfNoWindows() {
        if NSApp.windows.count == 0 {
            NSApp.hide(nil)
            NSApp.unhideWithoutActivation()
        }
    }
}

