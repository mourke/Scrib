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
        tagMenuItem.isEnabled = false // enable once a song plays
        favouriteMenuItem.isEnabled = false // enable once a song plays
        menu.addItem(.separator())
        
        profileMenuItem = menu.addItem(withTitle: "Go to Last.fm profile", action: #selector(openProfileUrl), keyEquivalent: "")
        profileMenuItem.isEnabled = false // enable once a user is authenticated
        menu.addItem(.separator())
        
        let settingsMenuItem = menu.addItem(withTitle: "Settings", action: #selector(displaySettingsWindow), keyEquivalent: ",")
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
        let settingsView = SettingsView()
        let tagWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                                  styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                                  backing: .buffered, defer: false)
        tagWindow.center()
        tagWindow.setFrameAutosaveName("Tag Window")
        tagWindow.contentView = NSHostingView(rootView: settingsView)
        activeWindow = tagWindow
    }
    
    /// Called when the "Favourite" status item is pressed.
    @objc func favouriteSong() {
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
        self.activeWindow = alertWindow
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            NSAnimationContext.runAnimationGroup({ [weak self] (context) in
                context.duration = 0.8
                self?.activeWindow?.animator().alphaValue = 0.0
            }) { [weak self] in
                self?.activeWindow = nil
            }
        }
    }
    
    /// Called when the "Settings" status item is pressed.
    @objc func displaySettingsWindow() {
        let settingsView = SettingsView()
        let settingsWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                                  styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                                  backing: .buffered, defer: false)
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("Settings Window")
        settingsWindow.contentView = NSHostingView(rootView: settingsView)
        
        activeWindow = settingsWindow
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
