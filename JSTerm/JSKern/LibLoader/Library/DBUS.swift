/*
DBUS.swift
 
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

import JavaScriptCore

func loaddbuslib(process: JavaScriptProcess) {
    let dbus_register: @convention(block) (String) -> Void = { id in
        kernel_dbus.register(id)
    }
    
    let dbus_unregister: @convention(block) (String) -> Void = { id in
        kernel_dbus.unregister(id)
    }
    
    let dbus_waitformsg: @convention(block) (String) -> String = { id in
        let semaphore = DispatchSemaphore(value: 0)
        process.semaphore = semaphore
        return kernel_dbus.waitformsg(id, semaphore: semaphore)
    }
    
    let dbus_sendmsg: @convention(block) (String, String) -> Void = { id,payload in
        kernel_dbus.sendmsg(id, payload: payload)
    }
    
    ld_add_symbol(symbol: dbus_register, name: "dbus_register", process: process)
    ld_add_symbol(symbol: dbus_unregister, name: "dbus_unregister", process: process)
    ld_add_symbol(symbol: dbus_waitformsg, name: "dbus_waitformsg", process: process)
    ld_add_symbol(symbol: dbus_sendmsg, name: "dbus_sendmsg", process: process)
}
