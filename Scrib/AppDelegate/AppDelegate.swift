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
    var startOnLoginObservation: NSKeyValueObservation!
    
    var scrobbleWorkItem: DispatchWorkItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = Updater.shared // initialise library
    
        LastFMKit.Auth.shared.apiKey = "bc15dd6972bc0f7c952273b34d253a6a"
        LastFMKit.Auth.shared.apiSecret = "d46ca773c61a3907c0b19c777c5bcf20"
        
        configureStatusItem()
        
        nowPlayingChanged() // update initial status
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(nowPlayingChanged), name: .MusicPlayerInfo, object: nil)
        
        signedInObservation = Settings.manager.observe(\.isSignedIn, options: [.new, .initial]) { [weak self] (settings, change) in
            self?.profileMenuItem.isEnabled = settings.isSignedIn
            self?.updateActionMenuItemsEnabled()
        }
        
        startOnLoginObservation = Settings.manager.observe(\.startOnLogin, options: [.new, .initial]) { (settings, change) in
            SMLoginItemSetEnabled("com.mourke.scrib-launcher" as CFString, settings.startOnLogin)
        }
    }
    
    @objc func nowPlayingChanged() {
        let isPlaying = musicApplication.playerState == .playing

        if isPlaying && Settings.manager.isSignedIn {
            let currentTrack = musicApplication.currentTrack!
            let song = currentTrack.name!
            let artist = currentTrack.artist!
            let duration = currentTrack.duration!.rounded(.down)
            let scrobblePercentage = Double(Settings.manager.scrobblePercentage)/100.0
            let dispatchAfterTime = min(max((scrobblePercentage * duration) - musicApplication.playerPosition!, 0), 240) // if the song is restarted past the scrobble distance, scrobble right away. Scrobbling occurs automatically after 4 minutes (240 seconds)
            
            let scrobbleTrack = ScrobbleTrack(name: song,
                                              artist: artist,
                                              album: currentTrack.album,
                                              albumArtist: currentTrack.albumArtist,
                                              positionInAlbum: currentTrack.trackNumber,
                                              duration: Int(duration),
                                              timestamp: Date.distantFuture, // set this when actually scrobbled
                                              chosenByUser: true)
            
            TrackProvider.updateNowPlaying(track: scrobbleTrack).resume()
            
            scrobbleWorkItem?.cancel()
            scrobbleWorkItem = DispatchWorkItem {
                scrobbleTrack.timestamp = Date()
                Scrobbler.shared.scrobble(scrobbleTrack)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + dispatchAfterTime, execute: scrobbleWorkItem)

            isCurrentTrackLoved = false
            var title = "\(song)\n\(artist)"
            
            if let album = currentTrack.album {
                title += " - \(album)"
            }
            
            currentScrobbleMenuItem.attributedTitle = NSAttributedString(string: title)
        } else {
            scrobbleWorkItem?.cancel()
            isCurrentTrackLoved = nil
            currentScrobbleMenuItem.attributedTitle = NSAttributedString(string: "Nothing playing")
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
        if !NSApp.isActive {
            NSApp.activate(ignoringOtherApps: true) // activate if not done already
        }
        window.makeKeyAndOrderFront(nil)
    }
}

