//
//  ConvertOneScheduleCodable.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct CodableLogrecords: Codable {
    var dateExecuted: String?
    var resultExecuted: String?
}

struct CodableConfigurationSchedule: Codable {
    var hiddenID: Int
    var offsiteserver: String?
    var dateStart: String
    var dateStop: String?
    var schedule: String
    var logrecords: [CodableLogrecords]?
    var delete: Bool?

    init(schedule: ConfigurationSchedule) {
        self.hiddenID = schedule.hiddenID
        self.offsiteserver = schedule.offsiteserver
        self.dateStart = schedule.dateStart
        self.dateStop = schedule.dateStop
        self.schedule = schedule.schedule
        self.delete = schedule.delete
        if (schedule.logrecords?.count ?? 0) > 0 { self.logrecords = [CodableLogrecords]() }
        for i in 0 ..< (schedule.logrecords?.count ?? 0) {
            var onelogrecord = CodableLogrecords()
            onelogrecord.dateExecuted = schedule.logrecords?[i].dateExecuted
            onelogrecord.resultExecuted = schedule.logrecords?[i].resultExecuted
            self.logrecords?.append(onelogrecord)
        }
    }
}
