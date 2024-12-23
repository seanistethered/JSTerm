/*
JSKernSave.swift
 
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

func saveusrfile(_ dictionary: [UInt16: String], to fileURL: URL) throws {
    let stringKeyedDict = dictionary.reduce(into: [String: String]()) { result, element in
        let (key, value) = element
        result[String(key)] = value
    }
    let encoder = JSONEncoder()
    let data = try encoder.encode(stringKeyedDict)
    try data.write(to: fileURL)
}

func loadusrfile(from fileURL: URL) throws -> [UInt16: String] {
    let data = try Data(contentsOf: fileURL)
    let decoder = JSONDecoder()
    let stringKeyedDict = try decoder.decode([String: String].self, from: data)
    var uint16KeyedDict = [UInt16: String]()
    for (stringKey, value) in stringKeyedDict {
        guard let uint16Key = UInt16(stringKey) else {
            throw NSError(domain: "InvalidKeyError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Found an invalid key that cannot be converted to UInt16."
            ])
        }
        uint16KeyedDict[uint16Key] = value
    }
    return uint16KeyedDict
}

func savesyscallfile(_ dictionary: [UInt16: [UInt8]], to fileURL: URL) throws {
    let stringKeyedDict = dictionary.reduce(into: [String: [UInt8]]()) { result, element in
        let (key, value) = element
        result[String(key)] = value
    }
    let encoder = JSONEncoder()
    let data = try encoder.encode(stringKeyedDict)
    try data.write(to: fileURL)
}
func loadsyscallfile(from fileURL: URL) throws -> [UInt16: [UInt8]] {
    let data = try Data(contentsOf: fileURL)
    let decoder = JSONDecoder()
    let stringKeyedDict = try decoder.decode([String: [UInt8]].self, from: data)
    var uint16KeyedDict = [UInt16: [UInt8]]()
    for (stringKey, value) in stringKeyedDict {
        guard let uint16Key = UInt16(stringKey) else {
            throw NSError(domain: "InvalidKeyError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Found a key that cannot be converted to UInt16."
            ])
        }
        uint16KeyedDict[uint16Key] = value
    }
    return uint16KeyedDict
}
