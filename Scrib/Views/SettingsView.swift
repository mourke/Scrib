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
import LastFMKit

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
            
            Button("Check for updates") {
                self.updater.checkForUpdates()
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
            
            Spacer(minLength: 50)
            
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
    
    private var user: User? {
        return settings.user
    }
    
    var body: some View {
        VStack {
            if settings.isSignedIn {
                HStack(alignment: .center, spacing: 30) {
                    userImage()
                        .resizable()
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(radius: 10)
                        .cornerRadius(50)
                    
                    VStack {
                        scrobbles()
                            .font(.title)
                            
                        Text("Scrobbles")
                            .opacity(0.5)
                    }
                    
                    VStack {
                        playlists()
                            .font(.title)
                        Text("Playlists")
                            .opacity(0.5)
                    }
                }
                HStack {
                    VStack(alignment: .leading) {
                        realName()
                            .font(.title)
                        scrobblingSince()
                    }
                    
                    Spacer(minLength: 50)
                    
                    Button("Sign Out") {
                        Auth.shared.removeSession()
                        self.settings.changeValue(\.user, to: nil)
                    }
                        /*.unredacted()*/
                }
            } else {
                Text("No user signed in")
                        /*.unredacted()*/
            }
        }
            /*.redacted(reason:  user == nil ? .placeholder : .init())*/
    }
    
    private func userImage() -> Image {
        if let image = user?.images[.large] {
            return Image(nsImage: NSImage(byReferencing: image))
        } else {
            return Image("Placeholder_Track")
        }
    }
    
    private func username() -> Text {
        if let username = user?.username {
            return Text(username)
        } else {
            return Text(verbatim: "Username")
        }
    }
    
    private func realName() -> Text {
        if let realName = user?.realName {
            return Text(realName)
        } else {
            return Text(verbatim: "Real Name")
        }
    }
    
    private func scrobbles() -> Text {
        if let playCount = user?.playCount {
        return Text("\(playCount)")
        } else {
            return Text(verbatim: "No")
        }
    }
    
    private func playlists() -> Text {
        if let playlistCount = user?.playlistCount {
            return Text("\(playlistCount)")
        } else {
            return Text(verbatim: "No")
        }
    }
    
    private func scrobblingSince() -> Text {
        if let date = user?.dateRegistered {
            return Text("Scrobbling since \(DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none))")
        } else {
            return Text("Not a user")
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
            HStack(spacing: 0) {
                Text("Made with ❤️ by Mark Bourke. Source available on ")
                    .font(.footnote)
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "https://github.com/mourke/Scrib")!)
                }) {
                    Text("Github")
                        .underline()
                }
                    .buttonStyle(HyperlinkButtonStyle())
                    .font(.footnote)
            }
            
            Spacer()
            Text(settings.appCopyright)
                .font(.footnote)
        }
            .padding(.vertical, 20)
    }
}

struct HyperlinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(0)
            .foregroundColor(configuration.isPressed ? Color(.linkColor).opacity(0.5) : Color(.linkColor))
            .background(Color.clear)
    }
}
