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
        onboardingPopover.contentViewController = NSHostingController(rootView: OnboardingView())
        
        menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        currentScrobbleMenuItem = menu.addItem(withTitle: "Nothing playing", action: nil, keyEquivalent: "")
        currentScrobbleMenuItem.isEnabled = false // never enable - it doesn't make sense for this to be clickable
        menu.addItem(.separator())
        
        favouriteMenuItem = menu.addItem(withTitle: "Favourite", action: #selector(favouriteSong), keyEquivalent: "L")
        tagMenuItem = menu.addItem(withTitle: "Tag...", action: #selector(displayTagWindow), keyEquivalent: "T")
        favouriteMenuItem.keyEquivalentModifierMask = [.command]
        tagMenuItem.keyEquivalentModifierMask = [.command]
        //tagMenuItem.isEnabled = false // enable once a song plays
        favouriteMenuItem.isEnabled = false // enable once a song plays
        menu.addItem(.separator())
        
        profileMenuItem = menu.addItem(withTitle: "Go to Last.fm profile", action: #selector(openProfileUrl), keyEquivalent: "")
        profileMenuItem.isEnabled = false // enable once a user is authenticated
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
        guard let track = musicApplication.currentTrack else { return }
        
        let tagWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 450, height: 250),
                                 styleMask: [.titled, .fullSizeContentView],
                                 backing: .buffered, defer: false)
        let tagView = TagView(image: track.artworks?().first?.data,
                              add: { [weak tagWindow, weak self, track] (type, tags) in
            tagWindow?.close()
            self?.hideIfNoWindows() // it's just the alert window that's been presented, return to previous app
            
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
        }, cancel: { [weak tagWindow, weak self] in
            tagWindow?.close()
            self?.hideIfNoWindows() // it's just the alert window that's been presented, return to previous app
        })
        tagWindow.center()
        tagWindow.setFrameAutosaveName("Tag Window")
        tagWindow.contentView = NSHostingView(rootView: tagView)
        
        showWindow(tagWindow)
    }
    
    /// Called when the "Favourite" status item is pressed.
    @objc func favouriteSong() {
        //TrackProvider.love(track: <#T##String#>, by: <#T##String#>, callback: <#T##LFMErrorCallback?##LFMErrorCallback?##(Error?) -> Void#>)
        //TrackProvider.unlove(track: <#T##String#>, by: <#T##String#>, callback: <#T##LFMErrorCallback?##LFMErrorCallback?##(Error?) -> Void#>)
        // TODO: API call
        let alertView = AlertView(imageName: "Heart", text: "Favourited")
        
        let alertWindow = NSWindow(contentRect: NSRect(origin: .zero, size: CGSize(width: 200, height: 200)),
                                  styleMask: [.fullSizeContentView],
                                  backing: .buffered, defer: false)
        alertWindow.collectionBehavior = .transient
        alertWindow.contentView = NSHostingView(rootView: alertView)
        alertWindow.isOpaque = false
        alertWindow.backgroundColor = .clear
        alertWindow.hasShadow = false
        alertWindow.center()
        
        showWindow(alertWindow)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            NSAnimationContext.runAnimationGroup({ [weak alertWindow] (context) in
                context.duration = 0.8
                alertWindow?.animator().alphaValue = 0.0
            }) { [weak alertWindow, weak self] in
                alertWindow?.close()
                self?.hideIfNoWindows() // it's just the alert window that's been presented, return to previous app
            }
        }
    }
    
    /// Called when the "Settings" status item is pressed.
    @objc func displaySettingsWindow() {
        let settingsView = SettingsView()
        let settingsWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 330),
                                  styleMask: [.titled, .closable, .fullSizeContentView],
                                  backing: .buffered, defer: false)
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("Settings Window")
        settingsWindow.title = "Settings"
        settingsWindow.contentView = NSHostingView(rootView: settingsView)
        
        let toolbar = SettingsToolbar()
        toolbar.navigationDelegate = settingsView
        settingsWindow.toolbar = toolbar
        
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
