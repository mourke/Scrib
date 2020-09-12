//
//  AppDelegate+MenuItem.swift
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
import OSLog
import LastFMKit

extension AppDelegate: NSMenuDelegate {
    
    func configureStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else {
            os_log("Status bar full.")
            NSApp.terminate(nil)
            return
        }
        
        button.image = NSImage(named: "NSStatusItem_Logo")
        button.action = #selector(statusItemButtonClicked(_:))
        button.sendAction(on: [.leftMouseDown, .rightMouseUp])
        
        onboardingPopover = NSPopover()
        onboardingPopover.contentSize = NSSize(width: 400, height: 300)
        onboardingPopover.behavior = .transient
        onboardingPopover.animates = false
        let onboardingView = OnboardingView {
            Auth.shared.getSession(username: $0, password: $1) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .failure(let error as LFMError):
                    // TODO: Error handling
                    break
                case .success(let session):
                    UserProvider.getInfo(on: session.username) { [weak self] (result) in
                        guard let self = self else { return }
                        switch result {
                        case .failure(let error as LFMError):
                            // TODO: Error handling
                            break
                        case .success(let user):
                            Settings.manager.changeValue(\.user, to: user)
                            self.onboardingPopover.performClose(nil)
                            self.statusItemButtonClicked(self.statusItem.button!) // open the menu
                        }
                    }.resume()
                }
            }.resume()
        }
        onboardingPopover.contentViewController = NSHostingController(rootView: onboardingView)
        
        menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        currentScrobbleMenuItem = menu.addItem(withTitle: "Nothing playing", action: nil, keyEquivalent: "")
        currentScrobbleMenuItem.isEnabled = false // never enable - it doesn't make sense for this to be clickable
        menu.addItem(.separator())
        
        favouriteMenuItem = menu.addItem(withTitle: "Favourite", action: #selector(favouriteSong), keyEquivalent: "f")
        tagMenuItem = menu.addItem(withTitle: "Tag...", action: #selector(displayTagWindow), keyEquivalent: "t")
        favouriteMenuItem.keyEquivalentModifierMask = [.command]
        tagMenuItem.keyEquivalentModifierMask = [.command]
        menu.addItem(.separator())
        
        profileMenuItem = menu.addItem(withTitle: "Go to Last.fm profile", action: #selector(openProfileUrl), keyEquivalent: "")
        menu.addItem(.separator())
        
        let settingsMenuItem = menu.addItem(withTitle: "Settings...", action: #selector(displaySettingsWindow), keyEquivalent: ",")
        settingsMenuItem.keyEquivalentModifierMask = [.command]
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "")
    }
    
    @objc func statusItemButtonClicked(_ button: NSButton) {
         guard let event = NSApp.currentEvent else {
            return
        }
        
        if (Settings.manager.isSignedIn || event.type == .rightMouseUp) {
            statusItem.menu = menu // add menu. there is no other way to present it natively
            button.performClick(nil) // manually perform click. once the menu is dismissed, remove the menu from status item
        } else {
            if onboardingPopover.isShown {
                onboardingPopover.performClose(button)
            } else {
                onboardingPopover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil // remove so action selector will be called
    }
    
    /// Called when the "Tag" status item is pressed.
    @objc func displayTagWindow() {
        if let tagWindow = tagWindow {
            showWindow(tagWindow)
            return
        }
        
        let track = musicApplication.currentTrack!
        
        let tagWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 450, height: 250),
                                 styleMask: [.titled, .fullSizeContentView],
                                 backing: .buffered, defer: false)
        tagWindow.isReleasedWhenClosed = false
        
        let tagView = TagView(image: track.artworks?().first?.data,
                              add: { [weak self, track] (type, tags) in
            self?.tagWindow?.close()
            self?.tagWindow = nil
            
            let artist = track.artist!
            
            switch type {
            case .album:
                AlbumProvider.add(tags: tags, to: track.album!, by: track.albumArtist ?? artist, callback: nil)
            case .artist:
                ArtistProvider.add(tags: tags, to: artist, callback: nil)
            case .track:
                TrackProvider.add(tags: tags, to: track.name!, by: artist, callback: nil)
            default:
                fatalError()
            }
        }, cancel: { [weak self] in
            self?.tagWindow?.close()
            self?.tagWindow = nil
        })
        tagWindow.center()
        tagWindow.setFrameAutosaveName("Tag Window")
        tagWindow.contentView = NSHostingView(rootView: tagView)
        
        self.tagWindow = tagWindow
        showWindow(tagWindow)
    }
    
    /// Called when the "Favourite" status item is pressed.
    @objc func favouriteSong() {
        favouriteMenuItem.isEnabled = false // stop multiple pressing while loading
        
        let loved = isCurrentTrackLoved! // this should never be called when this is nil. if it is there's an error
        let track = musicApplication.currentTrack!.name!
        let artist = musicApplication.currentTrack!.artist!
        let id = musicApplication.currentTrack!.id!()
        
        let callback: LFMErrorCallback = { [weak self] (error) in
            guard let self = self else { return }
            let isSameSongPlaying = self.musicApplication.currentTrack?.id?() == id // in case the song has changed in the time we've been calling the api
            
            if isSameSongPlaying {
                self.favouriteMenuItem.isEnabled = true // only put this back if it's the same song. if it's not the same song then changing this could be incorrect
            }
            
            guard error == nil else { return }
            
            if isSameSongPlaying {
                self.isCurrentTrackLoved?.toggle()
            }
            
            guard self.favouriteWindow == nil else { // don't present if already showing. this could happen if there is a really slow internet connection the song is changed multiple times and multiple favourite operations are running on the api and then all return at once
                return
            }
            
            let alertView = AlertView(imageName: "Heart", text: loved ? "Unfavourited" : "Favourited") // TODO: change image using sf symbols
            
            let alertWindow = NSWindow(contentRect: NSRect(origin: .zero, size: CGSize(width: 200, height: 200)),
                                      styleMask: [.fullSizeContentView],
                                      backing: .buffered, defer: false)
            alertWindow.collectionBehavior = .transient
            alertWindow.contentView = NSHostingView(rootView: alertView)
            alertWindow.isOpaque = false
            alertWindow.backgroundColor = .clear
            alertWindow.hasShadow = false
            alertWindow.isReleasedWhenClosed = false
            alertWindow.center()
            alertWindow.level = .statusBar
            
            self.favouriteWindow = alertWindow
            alertWindow.orderFrontRegardless()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                NSAnimationContext.runAnimationGroup({ [weak self] (context) in
                    context.duration = 0.8
                    self?.favouriteWindow?.animator().alphaValue = 0.0
                }) { [weak self] in
                    self?.favouriteWindow?.close()
                    self?.favouriteWindow = nil
                }
            }
        }
        
        if loved {
            TrackProvider.unlove(track: track, by: artist, callback: callback).resume()
        } else {
            TrackProvider.love(track: track, by: artist, callback: callback).resume()
        }
    }
    
    /// Called when the "Settings" status item is pressed.
    @objc func displaySettingsWindow() {
        if let settingsWindow = settingsWindow {
            showWindow(settingsWindow)
            return
        }
        
        let toolbar = SettingsToolbar()
        let settingsView = SettingsView(toolbar: toolbar)
        
        let settingsWindow = NSWindow(contentRect: .zero,
                                      styleMask: [.titled, .closable, .fullSizeContentView],
                                      backing: .buffered, defer: false)
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("Settings Window")
        settingsWindow.title = "Settings"
        settingsWindow.contentView = NSHostingView(rootView: settingsView)
        settingsWindow.toolbar = toolbar
        settingsWindow.isReleasedWhenClosed = false
        
        self.settingsWindow = settingsWindow
        showWindow(settingsWindow)
    }
    
    /// Called when the "Go to Last.fm profile" status item is pressed.
    @objc func openProfileUrl() {
        if let username = Settings.manager.user?.username {
            NSWorkspace.shared.open(URL(string: "https://www.last.fm/user/\(username)")!)
        }
    }
    
    /// Called when the "Quit" status item is pressed.
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
