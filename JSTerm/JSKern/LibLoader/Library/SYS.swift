/*
SYS.swift
 
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
import JavaScriptCore

func loadsyslib(process: JavaScriptProcess) {
    let sys_clock: @convention(block) () -> Double = {
        return getClock()
    }
    let sys_sleep: @convention(block) (UInt32) -> Void = { time in
        sleep(time)
    }
    let sys_usleep: @convention(block) (UInt32) -> Void = { time in
        usleep(time)
    }
    let sys_getenv: @convention(block) (String) -> String = { env in
        if let env = process.envp[env] {
            return env
        }
        return "undef"
    }
    let sys_setenv: @convention(block) (String,String) -> Void = { env,value in
        process.envp[env] = value
    }
    let sys_getenvs: @convention(block) () -> [String:String] = {
        return process.envp
    }
    let sys_hostname: @convention(block) () -> String = {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST)) // Buffer for hostname
        if gethostname(&hostname, Int(NI_MAXHOST)) == 0 {
            return String(cString: hostname) // Convert C string to Swift String
        } else {
            return "unknown" // Fallback in case of error
        }
    }
    let sys_shutdown: @convention(block) (Int32) -> Void = { status in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_SYSCTL) == 0 {
            exit(status)
        } else {
            warnthekernel(process: process.pid, callname: "SYS_SYSCTL")
        }
    }
    
    ld_add_symbol(symbol: sys_clock, name: "clock", process: process)
    ld_add_symbol(symbol: sys_sleep, name: "sleep", process: process)
    ld_add_symbol(symbol: sys_usleep, name: "usleep", process: process)
    ld_add_symbol(symbol: sys_getenv, name: "getenv", process: process)
    ld_add_symbol(symbol: sys_setenv, name: "setenv", process: process)
    ld_add_symbol(symbol: sys_getenvs, name: "getenvs", process: process)
    ld_add_symbol(symbol: sys_hostname, name: "gethostname", process: process)
    ld_add_symbol(symbol: sys_shutdown, name: "shutdown", process: process)
}
