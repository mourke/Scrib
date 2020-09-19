//
//  Notifier.swift
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
import LastFMKit
import UserNotifications

class Notifier : NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = Notifier()
    
    private let center = UNUserNotificationCenter.current()
    
    private static let editActionIdentifier = "EDIT_SCROBBLE_ACTION"
    private static let successfullScrobbleActionIdentifier = "SUCCESS_SCROBBLE_ACTION"
    private static let editScrobbleUrlKey = "EDIT_SCROBBLE_URL"
    
    private override init() {
        super.init()
        
        let editAction = UNNotificationAction(identifier: Notifier.editActionIdentifier,
                                              title: "Modify",
                                              options: .authenticationRequired)
        let successfullScrobbleCategory =
            UNNotificationCategory(identifier: Notifier.successfullScrobbleActionIdentifier,
                                   actions: [editAction], intentIdentifiers: [])
        
        center.setNotificationCategories([successfullScrobbleCategory])
        center.delegate = self
        
        center.requestAuthorization(options: [.alert]) { (granted, error) in }
    }
    
    
    func notifiy(of scrobble: ScrobbleResult) {
        guard Settings.manager.enableNotifications,
            let username = Settings.manager.user?.username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        
        let content = UNMutableNotificationContent()
        content.sound = nil
        
        if let error = scrobble.ignoredError {
            content.title = "Scrobble ignored"
            content.body = error.localizedDescription
            content.subtitle = "\(scrobble.trackName) - \(scrobble.artistName)"
        } else {
            content.title = "Scrobbled accepted"
            content.subtitle = scrobble.trackName
            content.categoryIdentifier = Notifier.successfullScrobbleActionIdentifier
            content.userInfo[Notifier.editScrobbleUrlKey] = "https://www.last.fm/user/\(username)/library/music/\(scrobble.artistName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)/_/\(scrobble.trackName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)"
            
            var body = scrobble.artistName
            
            if let album = scrobble.albumName {
                body += " - \(album)"
            }
            
            content.body = body
        }
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: nil)
        
        center.add(request) { (error) in
            guard error == nil else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.center.removeDeliveredNotifications(withIdentifiers: [uuidString])
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notifier.editActionIdentifier:
            let userInfo = response.notification.request.content.userInfo
            let url = userInfo[Notifier.editScrobbleUrlKey] as! String
            NSWorkspace.shared.open(URL(string: url)!)
        default:
           break
        }
        
        completionHandler()
    }
}
