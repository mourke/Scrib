//
//  SettingsToolbar.swift
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

class SettingsToolbar: NSToolbar, ObservableObject, NSToolbarDelegate {
    
    static let generalItemIdentifier = NSToolbarItem.Identifier(rawValue: "General")
    static let accountItemIdentifier = NSToolbarItem.Identifier(rawValue: "Account")
    static let aboutItemIdentifier = NSToolbarItem.Identifier(rawValue: "About")
    
    override var selectedItemIdentifier: NSToolbarItem.Identifier? {
        get {
            return super.selectedItemIdentifier
        } set {
            objectWillChange.send()
            super.selectedItemIdentifier = newValue
        }
    }
    
    private static let itemIdentifiers = [SettingsToolbar.generalItemIdentifier,
                                          SettingsToolbar.accountItemIdentifier,
                                          SettingsToolbar.aboutItemIdentifier]
    
    
    private static let identifier: NSToolbar.Identifier = "Settings Toolbar"
    
    init() {
        super.init(identifier: SettingsToolbar.identifier)
        
        delegate = self
        displayMode = .iconAndLabel
        selectedItemIdentifier = SettingsToolbar.generalItemIdentifier
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.target = self
        item.action = #selector(itemSelected(_:))
        
        switch itemIdentifier {
        case SettingsToolbar.generalItemIdentifier:
            item.label = "General"
            item.image = NSImage(named: NSImage.preferencesGeneralName)
        case SettingsToolbar.accountItemIdentifier:
            item.label = "Account"
            item.image = NSImage(named: NSImage.userAccountsName)
        case SettingsToolbar.aboutItemIdentifier:
            item.label = "About"
            item.image = NSImage(named: NSImage.infoName)
        default:
            fatalError()
        }
        
        return item
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return SettingsToolbar.itemIdentifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    @objc private func itemSelected(_ item: NSToolbarItem) {} // we need an action to enable the toolbar button. the change logic will be handled by the `selectedItemIdentifier` property of `NSToolbar`
}
