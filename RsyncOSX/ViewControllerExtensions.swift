//
//  ViewControllerExtensions.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length file_length

import Cocoa
import Foundation

protocol VcMain {
    var storyboard: NSStoryboard? { get }
}

extension VcMain {
    var storyboard: NSStoryboard? {
        return NSStoryboard(name: "Main", bundle: nil)
    }

    var sheetviewstoryboard: NSStoryboard? {
        return NSStoryboard(name: "SheetViews", bundle: nil)
    }

    // StoryboardOutputID
    var viewControllerAllOutput: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardOutputID")
            as? NSViewController)
    }

    // Sheetviews
    // Userconfiguration
    var viewControllerUserconfiguration: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as? NSViewController)
    }

    // Information about rsync output
    var viewControllerInformation: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardInformationID")
            as? NSViewController)
    }

    // AssistID
    var viewControllerAssist: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "AssistID")
            as? NSViewController)
    }

    // Move config files
    var viewControllerMove: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "MoveID")
            as? NSViewController)
    }

    // Profile
    var viewControllerProfile: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "ProfileID")
            as? NSViewController)
    }

    // About
    var viewControllerAbout: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "AboutID")
            as? NSViewController)
    }

    // Remote Info
    var viewControllerRemoteInfo: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardRemoteInfoID")
            as? NSViewController)
    }

    // Quick backup process
    var viewControllerQuickBackup: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardQuickBackupID")
            as? NSViewController)
    }

    // local and remote info
    var viewControllerInformationLocalRemote: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardLocalRemoteID")
            as? NSViewController)
    }

    // Estimating
    var viewControllerEstimating: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardEstimatingID")
            as? NSViewController)
    }

    // Progressbar process
    var viewControllerProgress: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardProgressID")
            as? NSViewController)
    }

    // Rsync userparams
    var viewControllerRsyncParams: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardRsyncParamsID")
            as? NSViewController)
    }

    // Edit
    var editViewController: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardEditID")
            as? NSViewController)
    }

    // RsyncCommand
    var rsynccommand: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "RsyncCommand")
            as? NSViewController)
    }

    // All profiles
    var allprofiles: NSViewController? {
        return (self.sheetviewstoryboard?.instantiateController(withIdentifier: "ViewControllerAllProfilesID")
            as? NSViewController)
    }
}

// Protocol for dismissing a viewcontroller
protocol DismissViewController: AnyObject {
    func dismiss_view(viewcontroller: NSViewController)
}

protocol SetDismisser {
    func dismissview(viewcontroller: NSViewController, vcontroller: ViewController)
}

extension SetDismisser {
    var dismissDelegateMain: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    var dismissDelegateSchedule: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
    }

    var dismissDelegateCopyFiles: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
    }

    var dismissDelegateNewConfigurations: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }

    var dimissDelegateSnapshot: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
    }

    var dismissDelegateLoggData: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }

    var dismissDelegateSsh: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
    }

    func dismissview(viewcontroller _: NSViewController, vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            self.dismissDelegateMain?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vctabschedule {
            self.dismissDelegateSchedule?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcrestore {
            self.dismissDelegateCopyFiles?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcnewconfigurations {
            self.dismissDelegateNewConfigurations?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcsnapshot {
            self.dimissDelegateSnapshot?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcloggdata {
            self.dismissDelegateLoggData?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcssh {
            self.dismissDelegateSsh?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        }
    }
}

// Protocol for deselecting rowtable
protocol DeselectRowTable: AnyObject {
    func deselect()
}

protocol Deselect {
    var deselectDelegateMain: DeselectRowTable? { get }
    var deselectDelegateSchedule: DeselectRowTable? { get }
}

extension Deselect {
    var deselectDelegateMain: DeselectRowTable? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    var deselectDelegateSchedule: DeselectRowTable? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
    }

    func deselectrowtable(vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            self.deselectDelegateMain?.deselect()
        } else {
            self.deselectDelegateSchedule?.deselect()
        }
    }
}

protocol Index {
    func index() -> Int?
    func indexfromwhere() -> ViewController
}

extension Index {
    func index() -> Int? {
        weak var getindexDelegate: GetSelecetedIndex?
        getindexDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        if getindexDelegate?.getindex() != nil {
            return getindexDelegate?.getindex()
        } else {
            getindexDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            return getindexDelegate?.getindex()
        }
    }

    func indexfromwhere() -> ViewController {
        weak var getindexDelegate: GetSelecetedIndex?
        getindexDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        if getindexDelegate?.getindex() != nil {
            return .vcsnapshot
        } else {
            getindexDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
            return .vctabmain
        }
    }
}

protocol Delay {
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void)
}

extension Delay {
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

protocol Connected {
    func connected(config: Configuration?) -> Bool
    func connected(server: String?) -> Bool
}

extension Connected {
    func connected(config: Configuration?) -> Bool {
        var port: Int = 22
        if let config = config {
            if config.offsiteServer.isEmpty == false {
                if let sshport: Int = config.sshport { port = sshport }
                let success = TCPconnections().testTCPconnection(config.offsiteServer, port: port, timeout: 1)
                return success
            } else {
                return true
            }
        }
        return false
    }

    func connected(server: String?) -> Bool {
        if let server = server {
            let port: Int = 22
            if server.isEmpty == false {
                let success = TCPconnections().testTCPconnection(server, port: port, timeout: 1)
                return success
            } else {
                return true
            }
        }
        return false
    }
}

protocol Abort: AnyObject {
    func abort()
}

extension Abort {
    func abort() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        view?.abortOperations()
    }
}

protocol Help: AnyObject {
    func help()
}

extension Help {
    func help() {
        NSWorkspace.shared.open(URL(string: "https://rsyncosx.netlify.app/post/rsyncosxdocs/")!)
    }
}

protocol GetOutput: AnyObject {
    func getoutput() -> [String]
}

protocol OutPut {
    var informationDelegateMain: GetOutput? { get }
}

extension OutPut {
    var informationDelegateMain: GetOutput? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func getinfo() -> [String] {
        return (self.informationDelegateMain?.getoutput()) ?? [""]
    }
}

protocol RsyncIsChanged: AnyObject {
    func rsyncischanged()
}

protocol NewRsync {
    func newrsync()
}

extension NewRsync {
    func newrsync() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        view?.rsyncischanged()
    }
}

protocol TemporaryRestorePath {
    func temporaryrestorepath()
}

protocol ChangeTemporaryRestorePath {
    func changetemporaryrestorepath()
}

extension ChangeTemporaryRestorePath {
    func changetemporaryrestorepath() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        view?.temporaryrestorepath()
    }
}

extension Sequence {
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
}

// Protocol for sorting
protocol Sorting {
    func sortbydate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]?
    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter?, sortdirection: Bool) -> [NSMutableDictionary]?
}

extension Sorting {
    func sortbydate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]? {
        let dateformatter = DateFormatter()
        dateformatter.formatterBehavior = .behavior10_4
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        let sorted = notsortedlist?.sorted { (d1, d2) -> Bool in
            if let d1 = dateformatter.date(from: (d1.value(forKey: DictionaryStrings.dateExecuted.rawValue) as? String) ?? "") {
                if let d2 = dateformatter.date(from: (d2.value(forKey: DictionaryStrings.dateExecuted.rawValue) as? String) ?? "") {
                    if d1.timeIntervalSince(d2) > 0 {
                        return sortdirection
                    } else {
                        return !sortdirection
                    }
                } else {
                    return !sortdirection
                }
            }
            return false
        }
        return sorted
    }

    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter?, sortdirection: Bool) -> [NSMutableDictionary]? {
        let sorted = notsortedlist?.sorted { (d1, d2) -> Bool in
            if let d1 = d1.value(forKey: self.filterbystring(filterby: sortby)) as? String,
               let d2 = d2.value(forKey: self.filterbystring(filterby: sortby)) as? String
            {
                if d1 > d2 { return sortdirection } else { return !sortdirection }
            }
            return false
        }
        return sorted
    }

    func filterbystring(filterby: Sortandfilter?) -> String {
        switch filterby ?? .none {
        case .localcatalog:
            return DictionaryStrings.localCatalog.rawValue
        case .profile:
            return DictionaryStrings.profile.rawValue
        case .offsitecatalog:
            return DictionaryStrings.offsiteCatalog.rawValue
        case .offsiteserver:
            return DictionaryStrings.offsiteServer.rawValue
        case .task:
            return DictionaryStrings.task.rawValue
        case .backupid:
            return DictionaryStrings.backupID.rawValue
        case .numberofdays:
            return DictionaryStrings.daysID.rawValue
        case .executedate:
            return DictionaryStrings.dateExecuted.rawValue
        default:
            return ""
        }
    }
}
