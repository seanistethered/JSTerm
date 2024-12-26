/*
System.swift
 
Copyright (C) 2024 fridakitten

This file is part of JSTerm.

FridaCodeManager is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FridaCodeManager is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FridaCodeManager. If not, see <https://www.gnu.org/licenses/>.

 ______    _     _         _____        __ _                           ______                    _       _   _
|  ___|  (_)   | |       /  ___|      / _| |                          |  ___|                  | |     | | (_)
| |_ _ __ _  __| | __ _  \ `--.  ___ | |_| |___      ____ _ _ __ ___  | |_ ___  _   _ _ __   __| | __ _| |_ _  ___  _ __
|  _| '__| |/ _` |/ _` |  `--. \/ _ \|  _| __\ \ /\ / / _` | '__/ _ \ |  _/ _ \| | | | '_ \ / _` |/ _` | __| |/ _ \| '_ \
| | | |  | | (_| | (_| | /\__/ / (_) | | | |_ \ V  V / (_| | | |  __/ | || (_) | |_| | | | | (_| | (_| | |_| | (_) | | | |
\_| |_|  |_|\__,_|\__,_| \____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___| \_| \___/ \__,_|_| |_|\__,_|\__,_|\__|_|\___/|_| |_|
Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
*/

import Foundation

class proc: Identifiable {
    let id: UUID = UUID()
    let name: String
    let pid: UInt16
    var uid: UInt16
    var gid: UInt16
    var syscalls: [UInt8] = []
    var process: JavaScriptProcess?
    
    init(name: String, pid: UInt16, uid: UInt16, gid: UInt16, sys: [UInt8] = []) {
        self.name = name
        self.pid = pid
        self.uid = uid
        self.gid = gid
    }
}

let SYSPERMERR: UInt32 = 0xDD

// CRITICAL
let SYS_SETUID: UInt8 = 0x01
let SYS_SETGID: UInt8 = 0x02
let SYS_USRMGR: UInt8 = 0x03

// USUAL
let SYS_FS_RD: UInt8 = 0x04
let SYS_FS_WR: UInt8 = 0x05
let SYS_EXEC: UInt8 = 0x06
let SYS_SYSCTL: UInt8 = 0x07

class PIDManager {
    private var currentPID: UInt16 = 0
    private var pids: [proc] = [proc(name: "Kernel Task", pid: 0, uid: 0, gid: 0, sys: [SYS_SETUID, SYS_SETGID, SYS_USRMGR, SYS_FS_RD, SYS_FS_WR, SYS_EXEC])]
    private var sys: [UInt16:[UInt8]] = [:]
    private var usr: [UInt16:String] = [:]
    private var pwd: [UInt16:String] = [:]
    private let queue = DispatchQueue(label: "pid.manager")
    
    func getuidname(ofuid: UInt16) -> String {
        return usr[ofuid] ?? "0"
    }
    
    func nextPID(name: String, parentpid: UInt16) -> UInt16 {
        return queue.sync {
            currentPID += 1
            let parentproc = pids.first(where: { $0.pid == parentpid })
            if let parentproc = parentproc {
                pids.append(proc(name: name, pid: currentPID, uid: parentproc.uid, gid: parentproc.gid))
                return currentPID
            } else {
                return 0
            }
        }
    }
    
    func attach_proc_to_pid(tc: [UInt8], pid: UInt16, process: JavaScriptProcess, external: Bool) -> Void {
        queue.sync {
            let proc = pids.first(where: { $0.pid == pid })
            if let proc = proc {
                proc.process = process
                if tc.isEmpty {
                    proc.syscalls = sys[proc.uid] ?? []
                } else {
                    proc.syscalls = tc
                }
                if !external {
                    proc.process?.terminal.name = {
                        let name = pids.first(where: { $0.pid == pid })?.name ?? ""
                        let path = URL(fileURLWithPath: name)
                        return path.lastPathComponent
                    }()
                    DispatchQueue.main.sync {
                        refresh()
                    }
                }
            }
        }
    }
    
    func kill_proc(pid: UInt16) -> Void {
        queue.sync {
            DispatchQueue.main.sync {
                let proc = self.pids.first(where: { $0.pid == pid })
                if let proc = proc {
                    proc.process?.terminal.input("\n")
                    proc.process?.terminate()
                    usleep(1000)
                    proc.process?.terminal.input("\n")
                    usleep(1000)
                    proc.process?.terminal.input("\n")
                    usleep(1000)
                    proc.process?.terminal.input("\n")
                    usleep(1000)
                    proc.process?.terminal.input("\n")
                    usleep(1000)
                    proc.process?.terminal.input("\n")
                }
            }
        }
    }
    
    func pidOver(pid: UInt16) -> Void {
        queue.sync {
            pids.removeAll(where: { $0.pid == pid })
        }
    }
    
    func listPID() -> [UInt16] {
        return queue.sync {
            return pids.map { $0.pid }
        }
    }
    
    func pidname(ofpid pid: UInt16) -> String {
        return queue.sync {
            do {
                let name = pids.first(where: { $0.pid == pid })?.name ?? ""
                let regex = try NSRegularExpression(pattern: JSTermRoot)
                let range = NSRange(name.startIndex..<name.endIndex, in: name)
                let result = regex.stringByReplacingMatches(in: name, options: [], range: range, withTemplate: "")
                return result
            } catch {}
            return ""
        }
    }
    func piduid(ofpid pid: UInt16) -> UInt16 {
        return queue.sync {
            let uid = pids.first(where: { $0.pid == pid })?.uid ?? 0
            return uid
        }
    }
    func pidgid(ofpid pid: UInt16) -> UInt16 {
        return queue.sync {
            let uid = pids.first(where: { $0.pid == pid })?.gid ?? 0
            return uid
        }
    }
    
    // PAM
    func hasperm(ofpid pid: UInt16, call: UInt8) -> UInt8 {
        return queue.sync {
            let syscall = pids.first(where: { $0.pid == pid })?.syscalls ?? []
            if syscall.contains(call) {
                return 0
            }
            return 1
        }
    }
    func setuid(topid pid: UInt16, touid: UInt16) -> UInt32 {
        return queue.sync {
            let proc = pids.first(where: { $0.pid == pid })
            let syscalls = proc?.syscalls ?? []
            if syscalls.contains(SYS_SETUID) {
                proc?.uid = touid
                return 0
            }
            return 1
        }
    }
    func setgid(topid pid: UInt16, togid: UInt16) -> UInt32 {
        return queue.sync {
            let proc = pids.first(where: { $0.pid == pid })
            let syscalls = proc?.syscalls ?? []
            if syscalls.contains(SYS_SETGID) {
                proc?.gid = togid
                return 0
            }
            return 1
        }
    }
    func setusername(frompid pid: UInt16, touid uid: UInt16, name: String) -> UInt32 {
        return queue.sync {
            let proc = pids.first(where: { $0.pid == pid })
            let syscalls = proc?.syscalls ?? []
            if syscalls.contains(SYS_USRMGR) {
                usr[uid] = name
                do {
                    try saveusrfile(usr, to: URL(fileURLWithPath: "\(JSTermKernel)/user"))
                } catch {}
                return 0
            }
            return 1
        }
    }
    func sysremove(ofuid uid: UInt16, call: UInt8) -> UInt32 {
        return queue.sync {
            if var array = sys[uid] {
                array.removeAll(where: { $0 == call })
                sys[uid] = array
                do {
                    try savesyscallfile(sys, to: URL(fileURLWithPath: "\(JSTermKernel)/syscall"))
                } catch {}
                return 0
            }
            return 1
        }
    }
    func sysadd(ofuid uid: UInt16, call: UInt8) -> UInt32 {
        return queue.sync {
            if var array = sys[uid] {
                if !array.contains(call) {
                    array.append(call)
                }
                sys[uid] = array
                do {
                    try savesyscallfile(sys, to: URL(fileURLWithPath: "\(JSTermKernel)/syscall"))
                } catch {}
                return 0
            } else {
                sys[uid] = [call]
            }
            return 1
        }
    }
    
    // PRVT
    func loadusr() {
        return queue.sync {
            do {
                usr = try loadusrfile(from: URL(fileURLWithPath: "\(JSTermKernel)/user"))
            } catch {}
        }
    }
    
    func saveusr() {
        return queue.sync {
            do {
                try saveusrfile(usr, to: URL(fileURLWithPath: "\(JSTermKernel)/user"))
            } catch {}
        }
    }
    func loadsys() {
        return queue.sync {
            do {
                sys = try loadsyscallfile(from: URL(fileURLWithPath: "\(JSTermKernel)/syscall"))
            } catch {}
        }
    }
    
    func savesys() {
        return queue.sync {
            do {
                try savesyscallfile(sys, to: URL(fileURLWithPath: "\(JSTermKernel)/syscall"))
            } catch {}
        }
    }
    func loadpwd() {
        return queue.sync {
            do {
                pwd = try loadusrfile(from: URL(fileURLWithPath: "\(JSTermKernel)/passwd"))
            } catch {}
        }
    }
    
    func savepwd() {
        return queue.sync {
            do {
                try saveusrfile(pwd, to: URL(fileURLWithPath: "\(JSTermKernel)/passwd"))
            } catch {}
        }
    }
}

func warnthekernel(process: UInt16, callname: String) -> Void {
    extern_deeplog("KERNEL SECURITY: Warning process \(process) tried to call \(callname) although sufficient permissions")
}
