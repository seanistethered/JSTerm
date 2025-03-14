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
        
        let type: String = {
            switch(JSTermKernelType)
            {
            case 0:
                return "Release"
            case 1:
                return "Debug"
            case 2:
                return "Alpha"
            case 3:
                return "Beta"
            default:
                return "Unknown"
            }
        }()
        
        DispatchQueue.main.async {
            self.terminal.terminalText.text.append("\(JSTermKernelName) \(JSTermKernelVersion) (\(type))\n")
        }
        
        beginClock()
        setupOSPrint()
        setupProc()
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
    
    private func startUserspace() -> Void {
        deeplog(msg: "[init] starting userspace")
        js_fork(semaphore: nil, path: "\(JSTermRoot)/sbin/shell.js", [], ["pwd":"/","bin":"/sbin:/bin:/games"], 0, 2)
    }
}

