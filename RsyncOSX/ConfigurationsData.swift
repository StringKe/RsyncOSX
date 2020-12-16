//
//  ConfigurationsData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 15/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class ConfigurationsData {
    // The main structure storing all Configurations for tasks
    var configurations: [Configuration]?
    var profile: String?
    // Initialized during startup
    var argumentAllConfigurations: [ArgumentsOneConfiguration]?
    // Datasource for NSTableViews
    // var configurationsDataSource: [NSMutableDictionary]?
    // valid hiddenIDs
    var validhiddenID: Set<Int>?
    var persistentstorage: PersistentStorage?

    func readconfigurationsplist() {
        if let store = self.persistentstorage?.configPLIST?.configurationsasdictionary {
            for i in 0 ..< store.count {
                let dict = store[i]
                var config = Configuration(dictionary: dict)
                config.profile = self.profile
                if ViewControllerReference.shared.synctasks.contains(config.task) {
                    if self.validhiddenID?.contains(config.hiddenID) == false {
                        self.configurations?.append(config)
                        let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: config)
                        self.argumentAllConfigurations?.append(rsyncArgumentsOneConfig)
                        self.validhiddenID?.insert(config.hiddenID)
                    }
                }
            }
        }
    }

    func readconfigurationsjson() {
        if let store = self.persistentstorage?.configJSON?.decodedjson {
            let transform = TransformConfigfromJSON()
            for i in 0 ..< store.count {
                if let configitem = store[i] as? DecodeConfiguration {
                    let transformed = transform.transform(object: configitem)
                    if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                        if self.validhiddenID?.contains(transformed.hiddenID) == false {
                            self.configurations?.append(transformed)
                            let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: transformed)
                            self.argumentAllConfigurations?.append(rsyncArgumentsOneConfig)
                            self.validhiddenID?.insert(transformed.hiddenID)
                        }
                    }
                }
            }
        }
    }

    init(profile: String?) {
        self.profile = profile
        self.configurations = nil
        self.argumentAllConfigurations = nil
        self.configurations = [Configuration]()
        self.validhiddenID = Set()
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        self.persistentstorage = PersistentStorage(profile: self.profile, whattoreadorwrite: .configuration)
        self.readconfigurationsjson()
        self.readconfigurationsplist()
    }
}
