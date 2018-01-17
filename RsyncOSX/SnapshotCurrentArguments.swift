//
//  SnapshotCurrentArguments.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// 1. ssh -p port user@host "mkdir ~/catalog"
// 2. ssh -p port user@host "cd ~/catalog; rm current; ln -s NN current"
//
// swiftlint:disable syntactic_sugar

import Foundation

final class SnapshotCurrentArguments: ProcessArguments {

    private var config: Configuration?
    private var args: Array<String>?
    private var command: String?

    private func remotearguments() {
        var remotearg: String?
        guard self.config != nil else { return }
        if self.config!.sshport != nil {
            self.args!.append("-p")
            self.args!.append(String(self.config!.sshport!))
        }
        if self.config!.offsiteServer.isEmpty == false {
            remotearg = self.config!.offsiteUsername + "@" + self.config!.offsiteServer
            self.args!.append(remotearg!)
        }
        let remotecatalog = config?.offsiteCatalog
        let snapshotnum = (config?.snapshotnum)! - 1
        let remotecommand = "cd " + remotecatalog!+"; " + "rm current;  " + "ln -s " + String(snapshotnum) + " current"
        self.args!.append(remotecommand)
        if self.config!.offsiteServer.isEmpty == false {
            self.command = "/usr/bin/ssh"
        } else {
            self.command = "/bin/sh"
        }
    }

    func getArguments() -> Array<String>? {
        return self.args
    }

    func getCommand() -> String? {
        return self.command
    }

    init (config: Configuration) {
        self.args = Array<String>()
        self.config = config
        self.remotearguments()
    }

}
