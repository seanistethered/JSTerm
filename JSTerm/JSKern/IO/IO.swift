//
//  IO.swift
//  JSTerm
//
//  Created by fridakitten on 12.03.25.
//

import Foundation

struct FilePermissions: Encodable, Decodable {
    var owner: UInt16
    var group: UInt16
    
    var owner_read: Bool
    var owner_write: Bool
    var owner_execute: Bool
    
    var group_read: Bool
    var group_write: Bool
    var group_execute: Bool
    
    var other_read: Bool
    var other_write: Bool
    var other_execute: Bool
}

struct PermissionResult {
    var canRead: Bool
    var canWrite: Bool
    var canExecute: Bool
}

func parseFilePermissions(from octal: UInt16) -> FilePermissions? {
    guard octal <= 0o777 else { return nil }
    
    let owner = (octal >> 6) & 0b111
    let group = (octal >> 3) & 0b111
    let other = octal & 0b111
    
    return FilePermissions(
        owner: owner,
        group: group,
        owner_read: (owner & 0b100) != 0,
        owner_write: (owner & 0b010) != 0,
        owner_execute: (owner & 0b001) != 0,
        group_read: (group & 0b100) != 0,
        group_write: (group & 0b010) != 0,
        group_execute: (group & 0b001) != 0,
        other_read: (other & 0b100) != 0,
        other_write: (other & 0b010) != 0,
        other_execute: (other & 0b001) != 0
    )
}

class jskern_perm_io {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    // thread safety
    let thread: DispatchQueue = DispatchQueue(label: "\(UUID())")
    
    // Get permissions from a file
    func fs_get_perm(path: String) -> FilePermissions? {
        return thread.sync {
            if path == "/"
            {
                return FilePermissions(owner: 0, group: 0, owner_read: true, owner_write: true, owner_execute: true, group_read: true, group_write: false, group_execute: true, other_read: true, other_write: false, other_execute: true)
            }
            
            let fullPath = "\(JSTermPerm)\(path)/perm"
            
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    let url = URL(fileURLWithPath: fullPath)
                    let data = try Data(contentsOf: url)
                    let permissions = try decoder.decode(FilePermissions.self, from: data)
                    return permissions
                } catch {
                    print("Error loading file: \(error.localizedDescription)")
                }
            }
            
            print("Error: File does not exist at path \(fullPath)")
            return nil
        }
    }
    
    private func saveFilePermissions(_ permissions: FilePermissions, to filePath: String) -> Bool {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(permissions)
            let url = URL(fileURLWithPath: filePath)
            try data.write(to: url)
            return true
        } catch {
            print("Failed to save permissions: \(error)")
            return false
        }
    }
    
    func fs_set_perm(path: String, perms: FilePermissions) {
        return thread.sync {
            let fullPath = "\(JSTermPerm)\(path)"
            
            if FileManager.default.fileExists(atPath: fullPath)
            {
                _ = saveFilePermissions(perms, to: "\(fullPath)/perm")
            } else {
                do {
                    try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: false)
                    _ = saveFilePermissions(perms, to: "\(fullPath)/perm")
                } catch {}
            }
        }
    }
    
    func fs_move_perm(path: String, to: String) -> Bool {
        return thread.sync {
            let sourcePath = "\(JSTermPerm)\(path)"
            let destinationPath = "\(JSTermPerm)\(to)"
            
            do {
                try FileManager.default.moveItem(atPath: sourcePath, toPath: destinationPath)
                return true
            } catch {
                return false
            }
        }
    }
    
    func fs_remove_perm(path: String) -> Bool {
        return thread.sync {
            let fullPath = "\(JSTermPerm)\(path)"
            
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    try FileManager.default.removeItem(atPath: fullPath)
                    return true
                } catch {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    func fs_permcheck(path: String, uid: UInt16, gid: UInt16) -> PermissionResult
    {
        var result: PermissionResult = PermissionResult(canRead: false, canWrite: false, canExecute: false)
        
        if let perms = fs_get_perm(path: path) {
            if uid == 0 {
                // superior user
                result.canRead = true
                result.canWrite = true
            }
            
            if perms.owner == uid {
                result.canRead = true
                result.canWrite = true
                if perms.owner_execute {
                    result.canExecute = true
                }
            }
            
            if perms.group == gid {
                if perms.group_read {
                    result.canRead = true
                }
                if perms.group_write {
                    result.canWrite = true
                }
                if perms.group_execute {
                    result.canExecute = true
                }
            }
            
            if perms.other_read {
                result.canRead = true
            }
            if perms.other_write {
                result.canWrite = true
            }
            if perms.group_execute {
                result.canExecute = true
            }
            
            return result
        }
        
        return result
    }
    
    func fs_treepermcheck(path: String, uid: UInt16, gid: UInt16) -> PermissionResult {
        var result = fs_permcheck(path: path, uid: uid, gid: gid)
        
        if uid == 0 {
            return result
        }
        
        if !result.canRead && !result.canWrite && !result.canExecute {
            return result
        }
        
        var currentPath = path
        while currentPath != "/" {
            let parentPath = URL(fileURLWithPath: currentPath).deletingLastPathComponent().path
            
            if parentPath == currentPath {
                break
            }
            
            let parentPerms = fs_permcheck(path: parentPath, uid: uid, gid: gid)
            
            if !(parentPerms.canRead && parentPerms.canExecute) {
                // path is inaccessible
                result.canWrite = false
                result.canRead = false
                result.canExecute = false
                break
            }
            
            currentPath = parentPath
        }
        
        return result
    }

}
