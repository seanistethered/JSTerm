/*
Init.swift
 
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

var extern_deeplog: (String) -> Void = {_ in}

class JavaScriptInit {
    private var context: JSContext?
    private var terminal: TerminalWindow
    
    init(terminal: TerminalWindow) {
        self.terminal = terminal
        self.context = JSContext()
        beginClock()
        
        extern_deeplog = { msg in
            self.deeplog(msg: msg)
        }
        
        deeplog(msg: "Frida-JS-Kernel-v0.1")
        deeplog(msg: "[*] setting up kernel_proc")
        deeplog(msg: "usr... okay")
        kernel_proc.loadusr()
        deeplog(msg: "sys... okay")
        kernel_proc.loadsys()
        deeplog(msg: "pwd... okay")
        kernel_proc.loadpwd()
        deeplog(msg: "[*] setting up kernel_fs")
        kernel_fs.append(path: "/sbin/shell.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/su.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/ls.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/rmdir.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/uname.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/env.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/id.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/hostname.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/mkserial.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/whoami.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/mkdir.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/ps.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/chown.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/pamctl.js", perm: [0x00,0x00,0x01])
        kernel_fs.append(path: "/sbin/serialctl.js", perm: [0x00,0x00,0x01])
        kernel_fs.kdone()
        deeplog(msg: "[*] setting up kernel_tc")
        kernel_tc.addTC(path: "/sbin/shell.js", tc: [SYS_FS_RD,SYS_EXEC])
        deeplog(msg: "starting userspace")
        
        js_fork(path: "\(JSTermRoot)/sbin/shell.js", [], ["pwd":"/","bin":"/bin:/sbin:/games"], 0)
    }
    
    private func deeplog(msg: String) {
        DispatchQueue.main.async {
            let timestamp = getClock()
            self.terminal.terminalText.text.append(String(format: "[%.6f] %@\n", timestamp, msg))
        }
    }
}

