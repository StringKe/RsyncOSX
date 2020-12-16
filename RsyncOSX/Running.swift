//
//  Running.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 07.02.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import AppKit
import Foundation

final class Running {
    let rsyncOSX = "no.blogspot.RsyncOSX"
    let rsyncOSXsched = "no.blogspot.RsyncOSXsched"
    var rsyncOSXisrunning: Bool = false
    var rsyncOSXschedisrunning: Bool = false
    var menuappnoconfig: Bool = true

    func verifyrsyncosxsched() -> Bool {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: (ViewControllerReference.shared.pathrsyncosxsched ?? "/Applications/") +
            ViewControllerReference.shared.namersyncosssched) else { return false }
        return true
    }

    init() {
        // Get all running applications
        let workspace = NSWorkspace.shared
        let applications = workspace.runningApplications
        let rsyncosx = applications.filter { ($0.bundleIdentifier == self.rsyncOSX) }
        let rsyncosxschde = applications.filter { ($0.bundleIdentifier == self.rsyncOSXsched) }
        if rsyncosx.count > 0 {
            self.rsyncOSXisrunning = true
        } else {
            self.rsyncOSXisrunning = false
        }
        if rsyncosxschde.count > 0 {
            self.rsyncOSXschedisrunning = true
            ViewControllerReference.shared.menuappisrunning = true
        } else {
            self.rsyncOSXschedisrunning = false
            ViewControllerReference.shared.menuappisrunning = false
        }
    }
}
