/*
FileSystem.swift
 
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

class FSSegment {
    var owner: UInt16 = 0
    var group: UInt16 = 0
    
    var read: Bool = true
    var write: Bool = true
    var execute: Bool = true
    
    var kern: Bool = false
    
    init(owner: UInt16, group: UInt16, read: Bool, write: Bool, execute: Bool, kern: Bool = false) {
        self.owner = owner
        self.group = group
        self.read = read
        self.write = write
        self.execute = execute
        self.kern = kern
    }
}

class FS_Protect {
    private var cache: [String:FSSegment] = [:]
    
    func append(path: String, perm: [UInt8]) {
        extern_deeplog("[kernel_fs.append] \(path): \(perm)")
        cache[path] = FSSegment(owner: 0, group: 0, read: (perm[0] == 1), write: (perm[1] == 1), execute: (perm[2] == 1), kern: true)
    }
    
    // perm read
    func isExecutable(path: String) -> Bool {
        guard let perm: FSSegment = cache[path] else { return true }
        return perm.execute
    }
    func isWritable(path: String) -> Bool {
        guard let perm: FSSegment = cache[path] else { return true }
        return perm.write
    }
    func isReadable(path: String) -> Bool {
        guard let perm: FSSegment = cache[path] else { return true }
        return perm.read
    }
    
    // ownership read
    func getOwner(path: String) -> UInt16 {
        guard let perm: FSSegment = cache[path] else { return 0 }
        return perm.owner
    }
    func getGroup(path: String) -> UInt16 {
        guard let perm: FSSegment = cache[path] else { return 0 }
        return perm.group
    }
    func isKernProt(path: String) -> Bool {
        guard let perm: FSSegment = cache[path] else { return false }
        return perm.kern
    }
    
    // perm mgmt
    func setReadable(path: String, value: Bool) {
        guard let _ = cache[path] else { return }
        cache[path]?.read = value
    }
    func setWritable(path: String, value: Bool) {
        guard let _ = cache[path] else { return }
        cache[path]?.write = value
    }
    func setExecutable(path: String, value: Bool) {
        guard let _ = cache[path] else { return }
        cache[path]?.execute = value
    }
    
    func setOwner(path: String, value: UInt16) {
        guard let _ = cache[path] else { return }
        cache[path]?.owner = value
    }
    func setGroup(path: String, value: UInt16) {
        guard let _ = cache[path] else { return }
        cache[path]?.group = value
    }
    
    // general stuff
    func isRegistered(path: String) -> Bool {
        guard let _ = cache[path] else { return false }
        return true
    }
}

class FS_trustcache {
    private var cache: [String:[UInt8]] = [:]
    
    func isTrusted(path: String) -> Bool {
        guard let tc: [UInt8] = cache[path] else { return false }
        return true
    }
    
    func addTC(path: String, tc: [UInt8], ownedbykern: Bool = false) {
        extern_deeplog("[kernel_tc.addTC] \(path): \(tc)")
        cache[path] = tc
    }
    
    func getTC(path: String) -> [UInt8] {
        guard let tc: [UInt8] = cache[path] else { return [] }
        return tc
    }
}
