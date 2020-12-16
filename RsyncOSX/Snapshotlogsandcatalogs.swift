//
//  SnapshotsLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class Snapshotlogsandcatalogs {
    var snapshotslogs: [NSMutableDictionary]?
    var scheduleloggdata: ScheduleLoggData?
    var config: Configuration?
    var outputprocess: OutputProcess?
    var snapshotcatalogs: [String]?
    var snapshotcatalogstodelete: [String]?
    var getsnapshots: Bool = true
    // var updateprogress: UpdateProgress?
    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void

    private func getremotecataloginfo() {
        self.outputprocess = OutputProcess()
        let arguments = RestorefilesArguments(task: .snapshotcatalogs,
                                              config: self.config,
                                              remoteFile: nil,
                                              localCatalog: nil,
                                              drynrun: nil)
        let command = RsyncProcessCmdClosure(arguments: arguments.getArguments(),
                                             config: nil,
                                             processtermination: self.processtermination,
                                             filehandler: self.filehandler)
        command.executeProcess(outputprocess: self.outputprocess)
    }

    private func reducetosnapshotlogs() {
        for i in 0 ..< (self.snapshotslogs?.count ?? 0) {
            if let dateRun = self.snapshotslogs?[i].object(forKey: DictionaryStrings.dateExecuted.rawValue) {
                if let secondssince = self.calculatedays(datestringlocalized: dateRun as? String ?? "") {
                    let dayssincelastbackup = String(format: "%.2f", secondssince / (60 * 60 * 24))
                    self.snapshotslogs?[i].setObject(dayssincelastbackup, forKey: DictionaryStrings.days.rawValue as NSCopying)
                }
            }
        }
    }

    private func mergeremotecatalogsandlogs() {
        for i in 0 ..< (self.snapshotcatalogs?.count ?? 0) {
            if self.snapshotcatalogs?[i].contains(".DS_Store") == false {
                let snapshotnum = "(" + (self.snapshotcatalogs?[i] ?? "").dropFirst(2) + ")"
                let filter = self.snapshotslogs?.filter { ($0.value(forKey: DictionaryStrings.resultExecuted.rawValue) as? String ?? "").contains(snapshotnum) }
                if filter?.count == 1 {
                    filter?[0].setObject(self.snapshotcatalogs![i], forKey: DictionaryStrings.snapshotCatalog.rawValue as NSCopying)
                } else {
                    let dict: NSMutableDictionary = [DictionaryStrings.snapshotCatalog.rawValue: self.snapshotcatalogs![i],
                                                     DictionaryStrings.dateExecuted.rawValue: "no log"]
                    self.snapshotslogs?.append(dict)
                }
            }
        }
        let sorted = self.snapshotslogs?.sorted { (di1, di2) -> Bool in
            let str1 = di1.value(forKey: DictionaryStrings.snapshotCatalog.rawValue) as? String
            let str2 = di2.value(forKey: DictionaryStrings.snapshotCatalog.rawValue) as? String
            let num1 = Int(str1?.dropFirst(2) ?? "") ?? 0
            let num2 = Int(str2?.dropFirst(2) ?? "") ?? 0
            if num1 <= num2 {
                return self.getsnapshots
            } else {
                return !self.getsnapshots
            }
        }
        self.snapshotslogs = sorted?.filter { ($0.value(forKey: DictionaryStrings.snapshotCatalog.rawValue) as? String)?.isEmpty == false }
    }

    private func calculatedays(datestringlocalized: String) -> Double? {
        guard datestringlocalized != "" else { return nil }
        let lastbackup = datestringlocalized.localized_date_from_string()
        let seconds: TimeInterval = lastbackup.timeIntervalSinceNow
        return seconds * (-1)
    }

    func preparecatalogstodelete() {
        for i in 0 ..< (self.snapshotslogs?.count ?? 0) - 1 {
            if self.snapshotslogs?[i].value(forKey: DictionaryStrings.selectCellID.rawValue) as? Int == 1 {
                if self.snapshotcatalogstodelete == nil { self.snapshotcatalogstodelete = [] }
                let snaproot = self.config?.offsiteCatalog
                let snapcatalog = self.snapshotslogs?[i].value(forKey: DictionaryStrings.snapshotCatalog.rawValue) as? String
                self.snapshotcatalogstodelete?.append((snaproot ?? "") + (snapcatalog ?? "").dropFirst(2))
            }
        }
    }

    func countbydays(num: Double) -> Int {
        var j: Int = 0
        guard self.snapshotslogs != nil else { return 0 }
        for i in 0 ..< (self.snapshotslogs?.count ?? 0) - 1 {
            let days: String = self.snapshotslogs?[i].value(forKey: DictionaryStrings.days.rawValue) as? String ?? "0"
            if Double(days)! >= num {
                j += 1
            }
        }
        return j - 1
    }

    init(config: Configuration,
         getsnapshots: Bool,
         processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void)
    {
        self.processtermination = processtermination
        self.filehandler = filehandler
        guard config.task == ViewControllerReference.shared.snapshot else { return }
        self.getsnapshots = getsnapshots
        self.config = config
        self.scheduleloggdata = ScheduleLoggData(hiddenID: config.hiddenID, sortascending: true)
        self.snapshotslogs = scheduleloggdata?.loggdata
        self.getremotecataloginfo()
    }

    func loggdata() {
        _ = self.outputprocess?.trimoutput(trim: .two)
        guard outputprocess?.error == false else { return }
        self.snapshotcatalogs = self.outputprocess?.trimoutput(trim: .one)
        if self.snapshotcatalogs?.count ?? 0 > 1 {
            if self.snapshotcatalogs![0] == "./." {
                self.snapshotcatalogs?.remove(at: 0)
            }
        }
        self.reducetosnapshotlogs()
        self.mergeremotecatalogsandlogs()
    }
}
