/*
Process.swift
 
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

import SwiftUI
import Foundation
import JavaScriptCore

func destroyJSContext(_ context: inout JSContext?) {
    guard let ctx = context else { return }
    ctx.exceptionHandler = nil
    ctx.exception = nil
}


class JavaScriptProcess {
    //private(set) var context: JSContext?
    private(set) var threads: [JSContext] = []
    private(set) var terminal: TerminalWindow
    private(set) var pid: UInt16
    private(set) var queue: DispatchQueue
    private(set) var path: String
    private(set) var args: [String]
    private(set) var runs: Bool
    private var desc: String
    var symbols: [String] = []
    var fd: [String] = Array(repeating: "", count: Int(UINT8_MAX))
    var envp: [String:String]
    
    init(terminal: TerminalWindow, path: String, args: [String], pid: UInt16, envp: [String:String], queue: DispatchQueue) {
        self.terminal = terminal
        //self.context = JSContext()
        self.threads = [JSContext()]
        self.pid = pid
        self.queue = queue
        self.path = path
        self.args = args
        self.envp = envp
        self.runs = false
        self.desc = ""
        
        loadlib(process: self, thread: 0)
    }
    
    func execute() {
        if !runs {
            loadJavaScriptFile(at: path, context: threads[0])
            _ = callFunction(named: "main", withArguments: [args], context: threads[0])
            runs = true
        }
    }
    
    func cthread(symbol: String) {
        let tqueue: DispatchQueue = DispatchQueue(label: "com.proc.thread.\(UUID())")
        let thread: JSContext = JSContext()
        threads.append(thread)
        let we = threads.count
        tqueue.async {
            loadlib(process: self, thread: we - 1)
            thread.evaluateScript(self.desc)
            _ = self.callFunction(named: symbol, withArguments: [], context: thread)
        }
    }
    
    func terminate() {
        // TODO: implement termination of processes
    }
    
    func loadJavaScriptFile(at filePath: String, context: JSContext) {
        do {
            let jsCode = try String(contentsOfFile: filePath, encoding: .utf8)
            desc = jsCode
            context.evaluateScript(jsCode)
        } catch {
            extern_deeplog("Kernel Exec Error: \(error)");
        }
    }

    func callFunction(named functionName: String, withArguments arguments: [Any], context: JSContext) -> JSValue? {
        guard let function = context.objectForKeyedSubscript(functionName) else {
            extern_deeplog("Function \(functionName) not found.")
            return nil
        }
        
        let result = function.call(withArguments: arguments)
        if let exception = context.exception {
            extern_deeplog("process \(pid): JavaScript Error in function \(functionName): \(exception.toString() ?? "Unknown error")")
            return nil
        }
        
        return result
    }

}
