//
//  ProcessCmd2.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

class ProcessCmd2: Delay {

    // Variable for reference to Process
    var processReference: Process?
    // Message to calling class
    weak var updateDelegate: UpdateProgress?
    // Command to be executed, normally rsync
    var command: String?
    // Arguments to command
    var arguments: [String]?
    // true if processtermination
    var termination: Bool = false
    // possible error ouput
    weak var possibleerrorDelegate: ErrorOutput?

    func setupdateDelegate(object: UpdateProgress) {
        self.updateDelegate = object
    }

    var observerFilehandle: NotificationToken?
    var observerProcessTermination: NotificationToken?

    func executeProcess(outputprocess: OutputProcess?) {
        // Process
        let task = Process()
        // If self.command != nil either alternativ path for rsync or other command than rsync to be executed
        if let command = self.command {
            task.launchPath = command
        } else {
            task.launchPath = Getrsyncpath().rsyncpath
        }
        task.arguments = self.arguments
        // If there are any Environmentvariables like
        // SSH_AUTH_SOCK": "/Users/user/.gnupg/S.gpg-agent.ssh"
        if let environment = Environment() {
            task.environment = environment.environment
        }
        // Pipe for reading output from Process
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        self.observerFilehandle = NotificationCenter.default.observe(name: NSNotification.Name.NSFileHandleDataAvailable, object: nil, queue: nil) { [weak self] notification in
            print("Entering notification handler block")
            guard let strongSelf = self else { return }
            print("\(strongSelf) received \(notification.name.rawValue)")
        }
        self.observerProcessTermination = NotificationCenter.default.observe(name: Process.didTerminateNotification, object: nil, queue: nil) { [weak self] notification in
                   print("Entering notification handler block")
                   guard let strongSelf = self else { return }
                   print("\(strongSelf) received \(notification.name.rawValue)")
               }

        task.launch()
    }

    init(command: String?, arguments: [String]?) {
        self.command = command
        self.arguments = arguments
        self.possibleerrorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    // Get the reference to the Process object.
       func getProcess() -> Process? {
           return self.processReference
       }

       // Terminate Process, used when user Aborts task.
       func abortProcess() {
           guard self.processReference != nil else { return }
           self.processReference!.terminate()
       }

    deinit {
        print("deinit \(self)")
    }
}

extension NotificationCenter {
    /// Convenience wrapper for addObserver(forName:object:queue:using:) that
    /// returns our custom NotificationToken.
    func observe(name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void ) -> NotificationToken {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}

/// Wraps the observer token received from NSNotificationCenter.addObserver(forName:object:queue:using:)
/// and automatically unregisters from the notification center on deinit.
final class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let token: Any

    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        print("NotificationToken deinit: unregistering")
        notificationCenter.removeObserver(token)
    }
}
