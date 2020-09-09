//
//  UpdateManager.swift
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

import Foundation
import Sparkle


class Updater: ObservableObject {
    
    /**
     Determines the frequency in which the the version check is performed.
     */
    enum CheckInterval: TimeInterval {
        /// Version check performed once a day.
        case daily = 86400
        /// Version check performed once a week.
        case weekly = 604800
        /// Version check performed once a month.
        case monthly = 2628e6
        
        static let arrayValue: [Self] = [.daily, .weekly, .monthly]
        
        var stringValue: String {
            switch self {
            case .daily:
                return "Daily"
            case .weekly:
                return "Weekly"
            case .monthly:
                return "Monthly"
            }
        }
    }
    
    static let shared = Updater()
    
    @Published var updateCheckInterval: CheckInterval {
        didSet {
            guard updateCheckInterval.rawValue != updater.updateCheckInterval else {
                return
            }
            updater.updateCheckInterval = updateCheckInterval.rawValue
        }
    }
    
    @Published var automaticallyChecksForUpdates: Bool {
        didSet {
            guard automaticallyChecksForUpdates != updater.automaticallyChecksForUpdates else {
                return
            }
            updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        }
    }
    
    private let updater = Sparkle.SUUpdater.shared()!
    private var automaticUpdatesObserver: NSKeyValueObservation!
    private var checkIntervalObserver: NSKeyValueObservation!
    
    
    init() {
        updater.feedURL = URL(string: "https://mourke.github.io/Scrib/appcast.xml")
        automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        updateCheckInterval = CheckInterval(rawValue: updater.updateCheckInterval) ?? .weekly
        
        automaticUpdatesObserver = updater.observe(\.automaticallyChecksForUpdates, options: .new) { (updater, change) in
            if let newValue = change.newValue,
                newValue != self.automaticallyChecksForUpdates { // stop infinite loop
                self.automaticallyChecksForUpdates = newValue
            }
        }
        
        checkIntervalObserver = updater.observe(\.updateCheckInterval, options: .new) { (updater, change) in
            if let newValue = change.newValue,
                newValue != self.updateCheckInterval.rawValue { // stop infinite loop
                self.updateCheckInterval = CheckInterval(rawValue: updater.updateCheckInterval) ?? .weekly
            }
        }
    }
    
    func checkForUpdates() {
        updater.checkForUpdates(nil)
    }
}
