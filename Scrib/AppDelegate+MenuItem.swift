//
//  AppDelegate+MenuItem.swift
//  Scrib
//
//  Created by Mark Bourke on 31/07/2020.
//  Copyright © 2020 Mark Bourke. All rights reserved.
//

import Cocoa
import SwiftUI
import OSLog

extension AppDelegate {
    
    func addStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else {
            os_log("Status bar full.")
            NSApp.terminate(nil)
            return
        }
        
        button.image = NSImage(named: "NSStatusItem_Logo")
        
        menu = NSMenu()
        menu.autoenablesItems = false
        statusItem.menu = menu
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
        
        menu.addItem(withTitle: "Settings", action: #selector(displaySettingsWindow), keyEquivalent: "")
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "")
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
        // TODO: call api
        
        let alertView = AlertView()
        let alertWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                                  styleMask: [.fullSizeContentView],
                                  backing: .buffered, defer: false)
        alertWindow.center()
        alertWindow.contentView = NSHostingView(rootView: alertView)
        activeWindow = alertWindow
        
        // TODO: auto fade the view out and return control to previous app
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
        
    }
    
    /// Called when the "Quit" status item is pressed.
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
