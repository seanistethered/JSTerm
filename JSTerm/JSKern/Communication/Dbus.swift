/*
Dbus.swift
 
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

class JS_DBUS {
    private var semaphore: DispatchSemaphore?
    private var data: String = ""
    
    func attachsemaphore(semaphore: DispatchSemaphore) -> Void {
        self.semaphore = semaphore
    }
    
    func waitformsg() -> String {
        semaphore?.wait()
        return data
    }
    
    func sendmsg(payload: String) {
        data = payload
        semaphore?.signal()
    }
}

class JS_DBUS_SYSTEM {
    private var bus: [String:JS_DBUS] = [:]
    
    func register(id: String) {
        bus[id] = JS_DBUS()
    }
    
    func unregister(id: String) {
        bus.removeValue(forKey: id)
    }
    
    func waitformsg(semaphore: DispatchSemaphore, id: String) -> String {
        guard let idbus: JS_DBUS = bus[id] else { return "" }
        idbus.attachsemaphore(semaphore: semaphore)
        return idbus.waitformsg()
    }
    
    func sendmsg(id: String, payload: String) {
        guard let idbus: JS_DBUS = bus[id] else { return }
        idbus.sendmsg(payload: payload)
    }
}
