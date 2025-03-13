/*
Spawn.swift
 
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

func js_slicecpy(originalContext: JSContext) -> JSContext {
    let newContext = JSContext()
    
    if let script = originalContext.globalObject.toString() {
        newContext?.evaluateScript(script)
    }

    return newContext!
}

func js_alloc_new_serial() -> TerminalWindow? {
    var window: TerminalWindow?
    DispatchQueue.main.sync {
        window = TerminalWindow()
        if let window = window {
            TerminalWindows.append(window)
            refresh()
        }
    }
    return window
}

func js_fork(semaphore: DispatchSemaphore?, path: String, _ args: [String],  _ envp: [String:String], _ parent: UInt16, _ mode: UInt8, _ symbol: String? = "main", _ window: TerminalWindow? = js_alloc_new_serial()) {
    let proc_queue: DispatchQueue = DispatchQueue(label: "\(UUID())")
    let mypid: UInt16 = kernel_proc.nextPID(name: path, parentpid: parent)
    if let window = window {
        switch(mode)
        {
            case 1: // default
                proc_queue.async {
                    let (input, deletion) = (window.input, window.deletion)
                    let proc = JavaScriptProcess(terminal: window, path: path, args: args, pid: mypid, envp: envp, queue: proc_queue)
                    kernel_proc.attach_proc_to_pid(pid: mypid, process: proc, external: true)
                    proc.execute(symbol ?? "main")
                    (window.input, window.deletion) = (input, deletion)
                    kernel_proc.pidOver(pid: proc.pid)
                    semaphore?.signal()
                }
                break
            case 2: // mkserial process
                semaphore?.signal()
                proc_queue.async {
                    let proc = JavaScriptProcess(terminal: window, path: path, args: args, pid: mypid, envp: envp, queue: proc_queue)
                    kernel_proc.attach_proc_to_pid(pid: mypid, process: proc, external: false)
                    proc.execute(symbol ?? "main")
                    kernel_proc.pidOver(pid: proc.pid)
                    DispatchQueue.main.sync {
                        if let index = TerminalWindows.firstIndex(where: { $0 === window }) {
                            TerminalWindows[index].terminalText.text = ""
                            TerminalWindows.remove(at: index)
                            refresh()
                        }
                    }
                }
                break
            case 3: // background process
                semaphore?.signal()
                proc_queue.async {
                    let (input, deletion) = (window.input, window.deletion)
                    let proc = JavaScriptProcess(terminal: window, path: path, args: args, pid: mypid, envp: envp, queue: proc_queue)
                    kernel_proc.attach_proc_to_pid(pid: mypid, process: proc, external: true)
                    proc.execute(symbol ?? "main")
                    (window.input, window.deletion) = (input, deletion)
                    kernel_proc.pidOver(pid: proc.pid)
                }
                break
            default:
                break
        }
    }
}

func js_kill(inpid: UInt16) {
    kernel_proc.kill_proc(pid: inpid)
}
