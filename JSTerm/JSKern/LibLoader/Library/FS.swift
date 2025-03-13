/*
FS.swift
 
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

func ssdlise_path(path: String?, cwd: String?) -> String {
    if (path ?? "").first == "/" {
        return "\(JSTermRoot)\(path ?? "")"
    } else {
        let current = "\(JSTermRoot)\(cwd ?? "")/\(path ?? "")"
        return current
    }
}
func chdir_path(path: String?, cwd: String?) -> String {
    guard let path = path else {
        return cwd ?? "/"
    }
    let combinedPath: String
    if path.hasPrefix("/") {
        combinedPath = path
    } else {
        let base = (cwd?.isEmpty == false) ? cwd! : "/"
        combinedPath = base.hasSuffix("/") ? base + path : base + "/" + path
    }
    
    return normalizePath(combinedPath)
}
private func normalizePath(_ fullPath: String) -> String {
    var components = fullPath.split(separator: "/").map(String.init).filter { !$0.isEmpty }
    var stack: [String] = []
    for component in components {
        switch component {
        case ".":
            continue
        case "..":
            if !stack.isEmpty {
                stack.removeLast()
            } else {
                continue
            }
        default:
            stack.append(component)
        }
    }
    let normalized = "/" + stack.joined(separator: "/")
    return normalized
}

func loadfslib(process: JavaScriptProcess) {
    /*
     @Brief function to validate if a certain path exists
     */
    let fs_validate: @convention(block) (String?) -> Bool = { rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        return FileManager.default.fileExists(atPath: path)
    }
    
    /*
     @Brief function to list what files and directories are in a certain directory
     */
    let fs_list: @convention(block) (String?) -> Any = { rawpath in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_RD) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath else {
            return jsDoThrowError("Sufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        
        guard kernel_prot.canReadQuestion(pid: process.pid, path: path) else {
            return jsDoThrowError("Permission denied")
        }
        
        do {
            let directory: [String] = try FileManager.default.contentsOfDirectory(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]))
            return directory
        } catch {
            return jsDoThrowError("Failed to get list of files")
        }
    }
    
    /*
     @Brief function to read the content of a certain file
     */
    let fs_read: @convention(block) (String?) -> Any = { rawpath in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_RD) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath else {
            return jsDoThrowError("Sufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        
        var value: ObjCBool = false
        let fullPath = ssdlise_path(path: path, cwd: process.envp["pwd"])
        
        guard FileManager.default.fileExists(atPath: fullPath, isDirectory: &value) else {
            return jsDoThrowError("File does not exist")
        }
        
        if value.boolValue {
            return jsDoThrowError("File is a directory")
        }
        
        guard kernel_prot.canReadQuestion(pid: process.pid, path: path) else {
            return jsDoThrowError("Permission denied")
        }
        
        guard let data = FileManager.default.contents(atPath: fullPath),
            let content = String(data: data, encoding: .utf8) else {
            return jsDoThrowError("Failed to read file")
        }
        
        return content
    }
    
    /*
     @Brief function to write content to a certain file
     */
    let fs_write: @convention(block) (String?, String?) -> Any = { rawpath, content in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath, let content = content else {
            return jsDoThrowError("Insufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        
        var value: ObjCBool = false
        let fullPath = ssdlise_path(path: path, cwd: process.envp["pwd"])
        
        guard FileManager.default.fileExists(atPath: fullPath, isDirectory: &value) else {
            return jsDoThrowError("File does not exist")
        }
        
        if value.boolValue {
            return jsDoThrowError("File is a directory")
        }
        
        guard kernel_prot.canWriteQuestion(pid: process.pid, path: path) else {
            return jsDoThrowError("Permission denied")
        }
        
        let url = URL(fileURLWithPath: fullPath)
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            return jsDoThrowError("Failed to write to file")
        }
        
        return true
    }
    
    /*
     @Brief function to remove a certain file
     */
    let fs_remove: @convention(block) (String?) -> Any = { rawpath in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath else {
            return jsDoThrowError("Sufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        
        var value: ObjCBool = false
        let fullPath = ssdlise_path(path: path, cwd: process.envp["pwd"])
        
        guard FileManager.default.fileExists(atPath: fullPath, isDirectory: &value) else {
            return jsDoThrowError("File does not exist")
        }
        
        if value.boolValue {
            return jsDoThrowError("File is a directory")
        }
        
        guard kernel_prot.canWriteQuestion(pid: process.pid, path: path) else {
            return jsDoThrowError("Permission denied")
        }
        
        do {
            try FileManager.default.removeItem(atPath: fullPath)
            _ = kernel_fs.fs_remove_perm(path: path)
            return true
        } catch {
            return jsDoThrowError("Failed to remove file")
        }
    }
    
    /*
     @Brief function to create a directory
     */
    let fs_mkdir: @convention(block) (String?) -> Any = { rawpath in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath else {
            return jsDoThrowError("Sufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        
        let parentdir: String = {
            var url: URL = URL(fileURLWithPath: path)
            url.deleteLastPathComponent()
            return url.path
        }()
        
        let fullPath = ssdlise_path(path: path, cwd: process.envp["pwd"])
        
        guard !FileManager.default.fileExists(atPath: fullPath) else {
            return jsDoThrowError("Directory already exists")
        }
        
        guard kernel_prot.canWriteQuestion(pid: process.pid, path: parentdir) else {
            return jsDoThrowError("Permission denied")
        }
        
        do {
            try FileManager.default.createDirectory(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]), withIntermediateDirectories: true, attributes: nil)
            kernel_fs.fs_set_perm(path: path, perms: FilePermissions(owner: kernel_proc.piduid(ofpid: process.pid), group: kernel_proc.pidgid(ofpid: process.pid), owner_read: true, owner_write: true, owner_execute: true, group_read: true, group_write: false, group_execute: true, other_read: true, other_write: false, other_execute: true))
            return true
        } catch {
            return jsDoThrowError("Failed to create directory")
        }
    }
    
    /*
     @Brief function to remove a directory
     */
    let fs_rmdir: @convention(block) (String?) -> Any = { rawpath in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath else {
            return jsDoThrowError("Sufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        
        var value: ObjCBool = false
        let fullPath = ssdlise_path(path: path, cwd: process.envp["pwd"])
        
        guard FileManager.default.fileExists(atPath: fullPath, isDirectory: &value) else {
            return jsDoThrowError("Directory does not exist")
        }
        
        if !value.boolValue {
            return jsDoThrowError("Directory is a file")
        }
        
        guard kernel_prot.canWriteQuestion(pid: process.pid, path: path) else {
            return jsDoThrowError("Permission denied")
        }
        
        do {
            try FileManager.default.removeItem(atPath: fullPath)
            _ = kernel_fs.fs_remove_perm(path: path)
            return true
        } catch {
            return jsDoThrowError("Failed to remoce directory")
        }
    }
    
    /*
     @Brief function to move a file or directory to a new place
     */
    let fs_move: @convention(block) (String?, String?) -> Any = { rawpath, destination in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) != 0, kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_RD) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath, let destination = destination else {
            return jsDoThrowError("Insufficient Arguments")
        }
        
        let sourcePath = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        let destPath = chdir_path(path: destination, cwd: process.envp["pwd"])
        
        let srcPerm = kernel_fs.fs_permcheck(path: sourcePath, uid: kernel_proc.piduid(ofpid: process.pid), gid: kernel_proc.pidgid(ofpid: process.pid))
        let destParent = URL(fileURLWithPath: destPath).deletingLastPathComponent().path
        let destPerm = kernel_fs.fs_permcheck(path: destParent, uid: kernel_proc.piduid(ofpid: process.pid), gid: kernel_proc.pidgid(ofpid: process.pid))
        
        let fullSourcePath = ssdlise_path(path: sourcePath, cwd: process.envp["pwd"])
        let fullDestPath = ssdlise_path(path: destPath, cwd: process.envp["pwd"])
        
        let parentdestdir: String = {
            var url: URL = URL(fileURLWithPath: fullDestPath)
            url.deleteLastPathComponent()
            return url.path
        }()
        
        guard FileManager.default.fileExists(atPath: fullSourcePath) else {
            return jsDoThrowError("Source path does not exist")
        }
        
        guard FileManager.default.fileExists(atPath: parentdestdir) else {
            return jsDoThrowError("Destination path doesnt exist")
        }
        
        guard srcPerm.canRead, srcPerm.canWrite, destPerm.canWrite, kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0 else {
            return jsDoThrowError("Permission denied")
        }
        
        do {
            try FileManager.default.moveItem(atPath: fullSourcePath, toPath: fullDestPath)
            _ = kernel_fs.fs_move_perm(path: sourcePath, to: destPath)
            return true
        } catch {
            return jsDoThrowError("Failed to move file or directory")
        }
    }

    
    /*
     @Brief function to create a new file
     */
    let fs_touch: @convention(block) (String?,String?) -> Any = { rawpath,content in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath, let context = content else {
            return jsDoThrowError("Insufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        
        let parentdir: String = {
            var url: URL = URL(fileURLWithPath: path)
            url.deleteLastPathComponent()
            return url.path
        }()
        
        guard FileManager.default.fileExists(atPath: parentdir) else {
            return jsDoThrowError("Destination path doesnt exist")
        }
        
        guard kernel_prot.canWriteQuestion(pid: process.pid, path: parentdir) else {
            return jsDoThrowError("Permission denied")
        }
        
        return FileManager.default.createFile(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]), contents: Data((content ?? "").utf8))
    }
    
    /*
     @Brief function to change the path
     */
    let fs_chdir: @convention(block) (String) -> Void = { path in
        let tempdir = chdir_path(path: path, cwd: process.envp["pwd"])
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: ssdlise_path(path: "", cwd: tempdir), isDirectory: &isDir), isDir.boolValue {
            process.envp["pwd"] = tempdir
        }
    }
    
    /*
     @Brief function to change file ownership
     */
    let fs_chown: @convention(block) (UInt16, String) -> UInt32 = { user, rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_prot.canWriteQuestion(pid: process.pid, path: path) {
            if var perms: FilePermissions = kernel_fs.fs_get_perm(path: path)
            {
                perms.owner = user
                kernel_fs.fs_set_perm(path: path, perms: perms)
                return 0
            }
        }
        return 1
    }
    
    /*
     @Brief function to change file groupship
     */
    let fs_chgrp: @convention(block) (UInt16, String) -> UInt32 = { user, rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_prot.canWriteQuestion(pid: process.pid, path: path) {
            if var perms: FilePermissions = kernel_fs.fs_get_perm(path: path)
            {
                perms.group = user
                kernel_fs.fs_set_perm(path: path, perms: perms)
                return 0
            }
        }
        return 1
    }
    
    /*
     @Brief function to change file permissions
     */
    let fs_chmod: @convention(block) (UInt16, String) -> UInt32 = { octal, rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_prot.canWriteQuestion(pid: process.pid, path: path) {
            if var perms: FilePermissions = kernel_fs.fs_get_perm(path: path)
            {
                let octalString = "\(octal)"
                if let octalValue = UInt16(octalString, radix: 8) {
                    if var nperms: FilePermissions = parseFilePermissions(from: octalValue)
                    {
                        nperms.owner = perms.owner
                        nperms.group = perms.group
                        kernel_fs.fs_set_perm(path: path, perms: nperms)
                        return 0
                    }
                }
            }
        }
        return 1
    }
    
    /*
     @Brief function to gather FilePermission structure
     */
    let fs_getperms: @convention(block) (String?) -> Any = { rawpath in
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_RD) != 0 {
            return jsDoThrowError("Permission denied")
        }
        
        guard let rawpath = rawpath else {
            return jsDoThrowError("Insufficient Arguments")
        }
        
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        let ssdpath = ssdlise_path(path: path, cwd: process.envp["pwd"])
        
        let parentdir: String = {
            var url: URL = URL(fileURLWithPath: path)
            url.deleteLastPathComponent()
            return url.path
        }()
        
        guard FileManager.default.fileExists(atPath: ssdpath) else {
            return jsDoThrowError("Path doesnt exist")
        }
        
        guard kernel_prot.canReadQuestion(pid: process.pid, path: parentdir) else {
            return jsDoThrowError("Permission denied")
        }
        
        guard let perms: FilePermissions = kernel_fs.fs_get_perm(path: path) else {
            return jsDoThrowError("Failed to retrieve perms")
        }
        
        let jsperm = JSValue(newObjectIn: process.context)!
        
        jsperm.setObject(perms.owner, forKeyedSubscript: "owner" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.group, forKeyedSubscript: "group" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.owner_read, forKeyedSubscript: "owner_read" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.owner_write, forKeyedSubscript: "owner_write" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.owner_execute, forKeyedSubscript: "owner_execute" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.group_read, forKeyedSubscript: "group_read" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.group_write, forKeyedSubscript: "group_write" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.group_execute, forKeyedSubscript: "group_execute" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.other_read, forKeyedSubscript: "other_read" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.other_write, forKeyedSubscript: "other_write" as (NSCopying & NSObjectProtocol))
        jsperm.setObject(perms.other_execute, forKeyedSubscript: "other_execute" as (NSCopying & NSObjectProtocol))
        
        return jsperm
    }
    
    /*
     @Brief calls to add the symbols to the JSBinary
     */
    ld_add_symbol(symbol: fs_validate, name: "fs_validate", process: process)
    ld_add_symbol(symbol: fs_list, name: "fs_list", process: process)
    ld_add_symbol(symbol: fs_read, name: "fs_read", process: process)
    ld_add_symbol(symbol: fs_write, name: "fs_write", process: process)
    ld_add_symbol(symbol: fs_remove, name: "fs_remove", process: process)
    ld_add_symbol(symbol: fs_move, name: "fs_move", process: process)
    ld_add_symbol(symbol: fs_getperms, name: "fs_getperms", process: process)
    ld_add_symbol(symbol: fs_mkdir, name: "mkdir", process: process)
    ld_add_symbol(symbol: fs_rmdir, name: "rmdir", process: process)
    ld_add_symbol(symbol: fs_rmdir, name: "rm", process: process)
    ld_add_symbol(symbol: fs_touch, name: "touch", process: process)
    ld_add_symbol(symbol: fs_chdir, name: "chdir", process: process)
    ld_add_symbol(symbol: fs_chown, name: "chown", process: process)
    ld_add_symbol(symbol: fs_chgrp, name: "chgrp", process: process)
    ld_add_symbol(symbol: fs_chmod, name: "chmod", process: process)
}
