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
import Swifter

var extern_deeplog: (String) -> Void = {_ in}

class JavaScriptInit {
    private var context: JSContext?
    private var terminal: TerminalWindow
    
    init(terminal: TerminalWindow) {
        self.terminal = terminal
        self.context = JSContext()
        
        DispatchQueue.main.async {
            self.terminal.terminalText.text.append("Frida-JS-Kernel-v1.0\n")
        }
        
        beginClock()
        setupOSPrint()
        setupProc()
        setupFS()
        setupTC()
        setupHost()
        startUserspace()
    }
    
    private func deeplog(msg: String) {
        DispatchQueue.main.async {
            let timestamp = getClock()
            self.terminal.terminalText.text.append(String(format: "[%.6f] %@\n", timestamp, msg))
        }
    }
    
    private func setupOSPrint() -> Void {
        extern_deeplog = { msg in
            self.deeplog(msg: msg)
        }
    }
    
    private func setupProc() -> Void {
        deeplog(msg: "[init] setting up kernel_proc")
        deeplog(msg: "usr... okay")
        kernel_proc.loadusr()
        deeplog(msg: "sys... okay")
        kernel_proc.loadsys()
        deeplog(msg: "pwd... okay")
        kernel_proc.loadpwd()
    }
    
    private func setupFS() -> Void {
        deeplog(msg: "[init] setting up kernel_fs")
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
    }
    
    private func setupTC() -> Void {
        deeplog(msg: "[init] setting up kernel_tc")
        kernel_tc.addTC(path: "/sbin/shell.js", tc: [SYS_FS_RD,SYS_EXEC])
    }
    
    private func setupHost() -> Void {
        deeplog(msg: "[init] setting up kernel_host")
        kernel_host.registerServer(name: "kernel")
        kernel_host.setServerAction(name: "kernel", path: "/proc") { request in
            var html = """
            <html>
            <head>
                <meta charset="UTF-8"/>
                <title>Process List</title>
                <style>
                    body {
                        font-family: sans-serif;
                    }
                    table {
                        border-collapse: collapse;
                        width: 50%;
                        margin: 20px auto;
                    }
                    th, td {
                        border: 1px solid #ccc;
                        padding: 8px 12px;
                        text-align: left;
                    }
                    th {
                        background-color: #f4f4f4;
                    }
                    tbody tr:nth-child(even) {
                        background-color: #f9f9f9;
                    }
                </style>
            </head>
            <body>
                <h1 style="text-align:center;">Process List</h1>
                <table>
                    <thead>
                        <tr>
                            <th>PID</th>
                            <th>UID</th>
                            <th>GID</th>
                            <th>Name</th>
                        </tr>
                    </thead>
                    <tbody>
            """
            
            let pids: [UInt16] = kernel_proc.listPID()
            for pid in pids {
                let processUID = kernel_proc.getuidname(ofuid: kernel_proc.piduid(ofpid: pid))
                let processGID = kernel_proc.getuidname(ofuid: kernel_proc.pidgid(ofpid: pid))
                let processName = kernel_proc.pidname(ofpid: pid)
                html += """
                    <tr>
                        <td>\(pid)</td>
                        <td>\(processUID)</td>
                        <td>\(processGID)</td>
                        <td>\(processName)</td>
                    </tr>
                """
            }
            
            // Close table and HTML
            html += """
                    </tbody>
                </table>
            </body>
            </html>
            """
            
            return HttpResponse.ok(.html(html))
        }
        kernel_host.startServer(name: "kernel", port: 50)
    }
    
    private func startUserspace() -> Void {
        kernel_fs.kdone()
        deeplog(msg: "[init] starting userspace")
        js_fork(path: "\(JSTermRoot)/sbin/shell.js", [], ["pwd":"/","bin":"/bin:/sbin:/games"], 0)
    }
}

