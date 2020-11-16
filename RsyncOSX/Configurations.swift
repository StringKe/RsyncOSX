//
//  Configurations.swift
//
//  The obect is the model for the Configurations but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  The object also holds various configurations for RsyncOSX and references to
//  some of the ViewControllers used in calls to delegate functions.
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

class Configurations: ReloadTable, SetSchedules {
    var profile: String?
    // The main structure storing all Configurations for tasks
    var configurations: [Configuration]?
    // Array to store argumenst for all tasks.
    // Initialized during startup
    var argumentAllConfigurations: [ArgumentsOneConfiguration]?
    // Datasource for NSTableViews
    var configurationsDataSource: [NSMutableDictionary]?
    // backup list from remote info view
    var quickbackuplist: [Int]?
    // Estimated backup list, all backups
    var estimatedlist: [NSMutableDictionary]?
    // remote and local info
    var localremote: [NSDictionary]?
    // remote info tasks
    var remoteinfoestimation: RemoteinfoEstimation?
    // Reference to check TCP-connections
    var tcpconnections: TCPconnections?
    // valid hiddenIDs
    var validhiddenID: Set<Int>?

    // Variable computes max hiddenID used
    // MaxhiddenID is used when new configurations are added.
    var maxhiddenID: Int {
        // Reading Configurations from memory
        if let configurations = self.configurations {
            if configurations.count > 0 {
                _ = configurations.sorted { (config1, config2) -> Bool in
                    if config1.hiddenID > config2.hiddenID {
                        return true
                    } else {
                        return false
                    }
                }
                let index = configurations.count - 1
                return configurations[index].hiddenID
            }
        } else {
            return 0
        }
        return 0
    }

    func setestimatedlistnil() -> Bool {
        if (self.estimatedlist?.count ?? 0) == (self.configurations?.count ?? 0) {
            return false
        } else {
            return true
        }
    }

    // Function for getting the profile
    func getProfile() -> String? {
        return self.profile
    }

    // Function for getting Configurations read into memory
    func getConfigurations() -> [Configuration]? {
        return self.configurations
    }

    // Function for getting arguments for all Configurations read into memory
    func getargumentAllConfigurations() -> [ArgumentsOneConfiguration]? {
        return self.argumentAllConfigurations
    }

    // Function for getting Configurations read into memory
    // as datasource for tableViews
    func getConfigurationsDataSource() -> [NSDictionary]? {
        return self.configurationsDataSource
    }

    // Function for getting all Configurations
    func getConfigurationsDataSourceSynchronize() -> [NSMutableDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations?.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSMutableDictionary]()
        for i in 0 ..< (configurations?.count ?? 0) {
            if configurations?[i].offsiteServer.isEmpty == true {
                configurations?[i].offsiteServer = "localhost"
            }
            if let config = self.configurations?[i] {
                let row: NSMutableDictionary = ConvertOneConfig(config: config).dict

                if self.quickbackuplist != nil {
                    let quickbackup = self.quickbackuplist!.filter { $0 == config.hiddenID }
                    if quickbackup.count > 0 {
                        row.setValue(1, forKey: DictionaryStrings.selectCellID.rawValue)
                    }
                }
                data.append(row)
            }
        }
        return data
    }

    func uniqueserversandlogins() -> [NSDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations?.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSDictionary]()
        for i in 0 ..< (configurations?.count ?? 0) {
            if configurations?[i].offsiteServer.isEmpty == true {
                configurations?[i].offsiteServer = "localhost"
            }
            if let config = self.configurations?[i] {
                let row: NSDictionary = ConvertOneConfig(config: config).dict
                let server = config.offsiteServer
                let user = config.offsiteUsername
                if server != "localhost" {
                    if data.filter({ $0.value(forKey: DictionaryStrings.offsiteServerCellID.rawValue) as? String ?? "" == server && $0.value(forKey: DictionaryStrings.offsiteUsernameID.rawValue) as? String ?? "" == user }).count == 0 {
                        data.append(row)
                    }
                }
            }
        }
        return data
    }

    // Function return arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    func arguments4rsync(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        switch argtype {
        case .arg:
            return allarguments?.arg ?? []
        case .argdryRun:
            return allarguments?.argdryRun ?? []
        case .argdryRunlocalcataloginfo:
            return allarguments?.argdryRunLocalcatalogInfo ?? []
        }
    }

    // Function return arguments for rsync, either arguments for
    // real runn or arguments for --dry-run for Configuration at selected index
    func arguments4restore(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        switch argtype {
        case .arg:
            return allarguments?.restore ?? []
        case .argdryRun:
            return allarguments?.restoredryRun ?? []
        default:
            return []
        }
    }

    func arguments4tmprestore(index: Int, argtype: ArgumentsRsync) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        switch argtype {
        case .arg:
            return allarguments?.tmprestore ?? []
        case .argdryRun:
            return allarguments?.tmprestoredryRun ?? []
        default:
            return []
        }
    }

    func arguments4verify(index: Int) -> [String] {
        let allarguments = self.argumentAllConfigurations?[index]
        return allarguments?.verify ?? []
    }

    func setCurrentDateonConfiguration(index: Int, outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        let hiddenID = self.gethiddenID(index: index)
        let numbers = number.stats()
        self.schedules?.addlogpermanentstore(hiddenID: hiddenID, result: numbers)
        if self.configurations?[index].task == ViewControllerReference.shared.snapshot {
            self.increasesnapshotnum(index: index)
        }
        let currendate = Date()
        self.configurations?[index].dateRun = currendate.en_us_string_from_date()
        // Saving updated configuration in memory to persistent store
        if ViewControllerReference.shared.json {
            PersistentStorageConfigurationJSON(profile: self.profile).saveconfigInMemoryToPersistentStore()
        } else {
            PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        }
        // Call the view and do a refresh of tableView
        self.reloadtable(vcontroller: .vctabmain)
        _ = Logging(outputprocess: outputprocess)
    }

    // Function is updating Configurations in memory (by record) and
    // then saves updated Configurations from memory to persistent store
    func updateConfigurations(_ config: Configuration, index: Int) {
        self.configurations?[index] = config
        if ViewControllerReference.shared.json {
            PersistentStorageConfigurationJSON(profile: self.profile).saveconfigInMemoryToPersistentStore()
        } else {
            PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        }
    }

    // Function deletes Configuration in memory at hiddenID and
    // then saves updated Configurations from memory to persistent store.
    // Function computes index by hiddenID.
    func deleteConfigurationsByhiddenID(hiddenID: Int) {
        let index = self.configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
        guard index > -1 else { return }
        self.configurations?.remove(at: index)
        if ViewControllerReference.shared.json {
            PersistentStorageConfigurationJSON(profile: self.profile).saveconfigInMemoryToPersistentStore()
        } else {
            PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        }
    }

    // Add new configurations
    func addNewConfigurations(dict: NSMutableDictionary) {
        var config = Configuration(dictionary: dict)
        config.hiddenID = self.maxhiddenID + 1
        self.configurations?.append(config)
        if ViewControllerReference.shared.json {
            let store = PersistentStorageConfigurationJSON(profile: self.profile)
            store.saveconfigInMemoryToPersistentStore()
        } else {
            let store = PersistentStorageConfiguration(profile: self.profile)
            store.saveconfigInMemoryToPersistentStore()
        }
    }

    func getResourceConfiguration(_ hiddenID: Int, resource: ResourceInConfiguration) -> String {
        if let result = self.configurations?.filter({ ($0.hiddenID == hiddenID) }) {
            switch resource {
            case .localCatalog:
                return result[0].localCatalog
            case .remoteCatalog:
                return result[0].offsiteCatalog
            case .offsiteServer:
                if result[0].offsiteServer.isEmpty {
                    return "localhost"
                } else {
                    return result[0].offsiteServer
                }
            case .task:
                return result[0].task
            case .backupid:
                return result[0].backupID
            case .offsiteusername:
                return result[0].offsiteUsername
            case .sshport:
                if result[0].sshport != nil {
                    return String(result[0].sshport!)
                } else {
                    return ""
                }
            }
        } else {
            return ""
        }
    }

    func getIndex(_ hiddenID: Int) -> Int {
        return self.configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
    }

    func gethiddenID(index: Int) -> Int {
        guard index != -1, index < (self.configurations?.count ?? -1) else { return -1 }
        return self.configurations?[index].hiddenID ?? -1
    }

    func removecompressparameter(index: Int, delete: Bool) {
        guard index < (self.configurations?.count ?? -1) else { return }
        if delete {
            self.configurations?[index].parameter3 = ""
        } else {
            self.configurations?[index].parameter3 = "--compress"
        }
    }

    func removeedeleteparameter(index: Int, delete: Bool) {
        guard index < (self.configurations?.count ?? -1) else { return }
        if delete {
            self.configurations?[index].parameter4 = ""
        } else {
            self.configurations?[index].parameter4 = "--delete"
        }
    }

    func removeesshparameter(index: Int, delete: Bool) {
        guard index < (self.configurations?.count ?? -1) else { return }
        if delete {
            self.configurations?[index].parameter5 = ""
        } else {
            self.configurations?[index].parameter5 = "-e"
        }
    }

    func increasesnapshotnum(index: Int) {
        let num = self.configurations?[index].snapshotnum ?? 0
        self.configurations![index].snapshotnum = num + 1
    }

    init(profile: String?) {
        self.profile = profile
        self.configurations = nil
        self.argumentAllConfigurations = nil
        self.configurationsDataSource = nil
        // Read and prepare configurations and rsync parameters
        let configurationsdata = ConfigurationsData(profile: profile)
        self.configurations = configurationsdata.configurations
        self.argumentAllConfigurations = configurationsdata.argumentAllConfigurations
        self.configurationsDataSource = configurationsdata.configurationsDataSource
        self.validhiddenID = configurationsdata.validhiddenID
        ViewControllerReference.shared.process = nil
    }
}
