/*
PAM.swift
 
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

func loadpamlib(process: JavaScriptProcess, thread: Int) {
    let pam_setuid: @convention(block) (UInt16) -> UInt32 = { uid in
        return kernel_proc.setuid(topid: process.pid, touid: uid)
    }
    let pam_setgid: @convention(block) (UInt16) -> UInt32 = { uid in
        return kernel_proc.setgid(topid: process.pid, togid: uid)
    }
    let pam_setusername: @convention(block) (UInt16, String) -> UInt32 = { uid,name in
        return kernel_proc.setusername(frompid: process.pid, touid: uid, name: name)
    }
    
    let pam_setsyscall: @convention(block) (UInt16, UInt8) -> UInt32 = { uid,call in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_USRMGR) == 0 {
            return kernel_proc.sysadd(ofuid: uid, call: call)
        } else {
            return SYSPERMERR
        }
    }
    let pam_unsetsyscall: @convention(block) (UInt16, UInt8) -> UInt32 = { uid,call in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_USRMGR) == 0 {
            return kernel_proc.sysremove(ofuid: uid, call: call)
        } else {
            return SYSPERMERR
        }
    }
    
    ld_add_symbol(symbol: pam_setuid, name: "setuid", process: process, thread: thread)
    ld_add_symbol(symbol: pam_setgid, name: "setgid", process: process, thread: thread)
    ld_add_symbol(symbol: pam_setusername, name: "setusername", process: process, thread: thread)
    ld_add_symbol(symbol: pam_setsyscall, name: "setsyscall", process: process, thread: thread)
    ld_add_symbol(symbol: pam_unsetsyscall, name: "unsetsyscall", process: process, thread: thread)
}
