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

func js_fork(path: String, tc: [UInt8] = [], _ args: [String],  _ envp: [String:String], _ parent: UInt16, _ window: TerminalWindow? = js_alloc_new_serial(), _ external: Bool = true) {
    let proc_queue: DispatchQueue = DispatchQueue(label: "\(UUID())")
    let mypid: UInt16 = kernel_proc.nextPID(name: path, parentpid: parent)
    if let window = window {
        if external {
            proc_queue.async {
                let proc = JavaScriptProcess(terminal: window, path: path, args: args, pid: mypid, envp: envp, queue: proc_queue)
                kernel_proc.attach_proc_to_pid(tc: tc, pid: mypid, process: proc, external: false)
                proc.execute("main")
                kernel_proc.pidOver(pid: proc.pid)
                DispatchQueue.main.sync {
                    if let index = TerminalWindows.firstIndex(where: { $0 === window }) {
                        TerminalWindows.remove(at: index)
                        refresh()
                    }
                }
            }
        } else {
            proc_queue.sync {
                let (input, deletion) = (window.input, window.deletion)
                let proc = JavaScriptProcess(terminal: window, path: path, args: args, pid: mypid, envp: envp, queue: proc_queue)
                kernel_proc.attach_proc_to_pid(tc: tc, pid: mypid, process: proc, external: true)
                proc.execute("main")
                (window.input, window.deletion) = (input, deletion)
                kernel_proc.pidOver(pid: proc.pid)
            }
        }
    }
}

func js_thread(function: String, _ parent: UInt16) {
    guard let proc_index: proc = kernel_proc.expose_process(ofpid: parent) else { return }
    guard let process: JavaScriptProcess = proc_index.process else { return }
    let thread_queue: DispatchQueue = DispatchQueue(label: "\(UUID())")
    let pid: UInt16 = kernel_proc.nextPID(name: "\(proc_index.name):thread", parentpid: parent)
    let thread: JavaScriptProcess = JavaScriptProcess(terminal: process.terminal, path: process.path, args: process.args, pid: pid, envp: process.envp, queue: thread_queue)
    thread_queue.async {
        thread.execute(function)
        kernel_proc.pidOver(pid: pid)
    }
}

func js_kill(inpid: UInt16) {
    kernel_proc.kill_proc(pid: inpid)
}
