//
//  SettingsView.swift
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

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var toolbar: SettingsToolbar
    
    var body: some View {
        containedView()
            .fixedSize()
            .padding(.horizontal, 100)
            .padding(.vertical, 20);
    }
    
    private func containedView() -> AnyView {
        switch toolbar.selectedItemIdentifier {
        case SettingsToolbar.generalItemIdentifier:
            return AnyView(GeneralView())
        case SettingsToolbar.accountItemIdentifier:
            return AnyView(AccountView())
        case SettingsToolbar.aboutItemIdentifier:
            return AnyView(AboutView())
        default:
            fatalError()
        }
    }
}

fileprivate struct GeneralView: View {
    
    @ObservedObject private var settings = Settings.manager
    @ObservedObject private var updater  = Updater.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            
            Toggle(isOn: $updater.automaticallyChecksForUpdates) {
                Text("Automatic updates")
            }
            
            Picker(selection: Binding<Int>(get: { Updater.CheckInterval.arrayValue.firstIndex(of: self.updater.updateCheckInterval)! },
                                                set: { self.updater.updateCheckInterval = Updater.CheckInterval.arrayValue[$0] }),
                   label: Text("Update frequency: ").fixedSize()) {
                ForEach(0 ..< Updater.CheckInterval.arrayValue.count) {
                    Text(Updater.CheckInterval.arrayValue[$0].stringValue)
                }
            }
            
            Button(action: {
                self.updater.checkForUpdates()
            }) {
                Text("Check for updates")
            }
            
            Spacer(minLength: 50)
            
            Toggle(isOn: Binding(get: { self.settings.startOnLogin },
                                 set: { self.settings.changeValue(\.startOnLogin, to: $0) })) {
                Text("Start on login")
            }
            
            Toggle(isOn: Binding(get: { self.settings.enableNotifications },
                                 set: { self.settings.changeValue(\.enableNotifications, to: $0) })) {
                Text("Show notifications")
            }
            
            Spacer()
            
            Toggle(isOn: Binding(get: { self.settings.scrobbling },
                                 set: { self.settings.changeValue(\.scrobbling, to: $0) })) {
                Text("Enable scrobbling")
            }
            
            Slider(value: Binding(get: { Float(self.settings.scrobblePercentage) },
                                  set: { self.settings.changeValue(\.scrobblePercentage, to: Int($0)) }),
                   in: 50...100,
                   minimumValueLabel: Text("").fixedSize(),
                   maximumValueLabel: Text("\(self.settings.scrobblePercentage)% of song").fixedSize()) {
                    Text("Scrobble at")
            }
                .frame(minWidth: 350)
                .disabled(!settings.scrobbling)
        }
    }
}

fileprivate struct AccountView: View {
    
    @ObservedObject private var settings = Settings.manager
    
    var body: some View {
        VStack {
            if settings.isSignedIn {
                HStack {
                    Image(nsImage: NSImage(byReferencing: settings.user!.images[.extraLarge]!))
                    VStack {
                        Text(settings.user!.username)
                        Text(settings.user!.realName)
                        Text(settings.user!.country)
                        Text(settings.user!.dateRegistered.description)
                        Text("\(settings.user!.playCount) scrobbles")
                        Text("\(settings.user!.playlistCount) playlists")
                        Text("\(settings.user!.age) years old")
                    }
                }
            } else {
                Text("No user signed in")
            }
        }
    }
}

fileprivate struct AboutView: View {
    
    @ObservedObject private var settings = Settings.manager
    
    var body: some View {
        VStack {
            Image(nsImage: settings.appImage)
                .resizable()
                .frame(width: 75, height: 75)
                .cornerRadius(15)
            Text(settings.appName)
                .font(.body)
            Spacer(minLength: 2)
            Text("v\(settings.appVersion) (\(settings.appBuildNumber))")
                .opacity(0.6)
                .font(.caption)
            Spacer(minLength: 25)
            Text("Made with ❤️ by Mark Bourke. Source available on Github.")
                .font(.footnote)
            Spacer()
            Text(settings.appCopyright)
                .font(.footnote)
        }
            .padding(.vertical, 20)
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
