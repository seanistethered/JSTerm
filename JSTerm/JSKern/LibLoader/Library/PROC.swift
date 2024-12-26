/*
PROC.swift
 
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

import JavaScriptCore

func loadproclib(process: JavaScriptProcess) {
    let jsinit_exec: @convention(block) (String,[String],Bool) -> Void = { rawpath,args,external in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"] ?? "/")
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_EXEC) == 0 {
            var tc: [UInt8] = []
            if kernel_tc.isTrusted(path: path) {
                tc = kernel_tc.getTC(path: path)
            }
            if external {
                js_fork(path: "\(JSTermRoot)\(path)", tc: tc, args, process.envp, process.pid)
            } else {
                js_fork(path: "\(JSTermRoot)\(path)", tc: tc, args, process.envp, process.pid, process.terminal, false)
            }
        } else {
            warnthekernel(process: process.pid, callname: "SYS_EXEC")
        }
    }
    let jsinit_kill: @convention(block) (UInt16) -> Void = { selpid in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_SYSCTL) == 0 {
            js_kill(inpid: selpid)
        }
    }
    let jsinit_getallpid: @convention(block) () -> [UInt16] = {
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_SYSCTL) == 0 {
            return kernel_proc.listPID()
        } else {
            warnthekernel(process: process.pid, callname: "SYS_SYSCTL")
            return []
        }
    }
    let jsinit_getnamepid: @convention(block) (UInt16) -> String = { ofpid in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_SYSCTL) == 0 {
            return kernel_proc.pidname(ofpid: ofpid)
        } else {
            warnthekernel(process: process.pid, callname: "SYS_SYSCTL")
            return "SYSPERMERR"
        }
    }
    let proc_getusername: @convention(block) (UInt16) -> String = { ofuid in
        return kernel_proc.getuidname(ofuid: ofuid)
    }
    let jsinit_getuidpid: @convention(block) (UInt16) -> UInt16 = { ofpid in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_SYSCTL) == 0 {
            return kernel_proc.piduid(ofpid: ofpid)
        } else {
            warnthekernel(process: process.pid, callname: "SYS_SYSCTL")
            return UInt16(SYSPERMERR)
        }
    }
    let jsinit_getgidpid: @convention(block) (UInt16) -> UInt16 = { ofpid in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_SYSCTL) == 0 {
            return kernel_proc.pidgid(ofpid: ofpid)
        } else {
            warnthekernel(process: process.pid, callname: "SYS_SYSCTL")
            return 0
        }
    }
    let jsinit_getpid: @convention(block) () -> UInt16 = {
        return process.pid
    }
    let jsinit_getuid: @convention(block) () -> UInt16 = {
        return kernel_proc.piduid(ofpid: process.pid)
    }
    let jsinit_getgid: @convention(block) () -> UInt16 = {
        return kernel_proc.pidgid(ofpid: process.pid)
    }

    ld_add_symbol(symbol: jsinit_exec, name: "exec", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_kill, name: "kill", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_getallpid, name: "getallpid", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_getnamepid, name: "getnamepid", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_getuidpid, name: "getuidpid", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_getgidpid, name: "getgidpid", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_getpid, name: "getpid", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_getuid, name: "getuid", process: process, thread: 0)
    ld_add_symbol(symbol: jsinit_getgid, name: "getgid", process: process, thread: 0)
    ld_add_symbol(symbol: proc_getusername, name: "getusername", process: process, thread: 0)
}
