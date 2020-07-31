//
//  AppDelegate.swift
//  Scrib
//
//  Created by Mark Bourke on 30/07/2020.
//  Copyright © 2020 Mark Bourke. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var activeWindow: NSWindow? {
        didSet {
            if let window = activeWindow {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            } else {
                NSApp.deactivate()
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
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

