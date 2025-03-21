/*
JSMachine.swift
 
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

let JSTermRoot: String = "\(NSHomeDirectory())/Documents/rootfs"
let JSTermKernel: String = "\(NSHomeDirectory())/Documents/kernelfs"
let JSTermPerm: String = "\(NSHomeDirectory())/Documents/permfs"
var JSTermClock: Double = 0.0                                           // the clock of the machine
let JSTermKernelVersion: String = "0.1"                                 // the version of the kerne
let JSTermKernelName: String = "JSKern"                                 // the name of the kernek
let JSTermKernelType: UInt8 = 1                                         // 0 = Release / 1 = Alpha / 2 = Beta

func beginClock() -> Void {
    JSTermClock = Date().timeIntervalSince1970
}

func getClock() -> Double {
    return Date().timeIntervalSince1970 - JSTermClock
}

/*
 @Brief Objc Translation for now
 */
@objc class JSTermMachine: NSObject {
    @objc var ObjJSTermRoot: String = JSTermRoot
    @objc var ObjJSTermKernel: String = JSTermKernel
    @objc var ObjJSTermPerm: String = JSTermPerm
    @objc var ObjJSTermKernelVersion: String = JSTermKernelVersion
    @objc var ObjJSTermKernelName: String = JSTermKernelName
    @objc var ObjJSTermKernelType: UInt8 = JSTermKernelType
    
    @objc func ObjJSGetClock() -> Double {
        return getClock()
    }
}
