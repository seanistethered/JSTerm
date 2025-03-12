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
    let fs_validate: @convention(block) (String?) -> Bool = { rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_RD) == 0, kernel_fs.isReadable(path: path) {
            return FileManager.default.fileExists(atPath: path)
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_RD")
        }
        return false
    }
    let fs_list: @convention(block) (String?) -> [String] = { rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_RD) == 0, kernel_fs.isReadable(path: path) {
            do {
                let directory: [String] = try FileManager.default.contentsOfDirectory(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]))
                return directory
            } catch {
                extern_deeplog("Kernel I/O: \(error)")
            }
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_RD")
        }
        return []
    }
    let fs_read: @convention(block) (String?) -> Any = { rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_RD) == 0, kernel_fs.isReadable(path: path) {
            if let data = FileManager.default.contents(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"])), let content = String(data: data, encoding: .utf8) {
                return content
            }
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_RD")
        }
        return ""
    }
    let fs_write: @convention(block) (String?,String?) -> Void = { rawpath,content in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isWritable(path: path) {
            let url = URL(fileURLWithPath: ssdlise_path(path: path, cwd: process.envp["pwd"]))
            do {
                try content?.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                extern_deeplog("Kernel I/O: \(error)")
            }
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_WR")
        }
    }
    let fs_remove: @convention(block) (String?) -> Void = { rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isWritable(path: path) {
            do {
                try FileManager.default.removeItem(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]))
            } catch {
                extern_deeplog("Kernel I/O: \(error)")
            }
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_WR")
        }
    }
    
    let fs_mkdir: @convention(block) (String?) -> Void = { rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isWritable(path: path) {
            do {
                try FileManager.default.createDirectory(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]), withIntermediateDirectories: true, attributes: nil)
            } catch {
                extern_deeplog("KERNEL I/O: \(error)")
            }
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_WR")
        }
    }
    let fs_rmdir: @convention(block) (String?) -> Void = { rawpath in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isWritable(path: path) {
            do {
                try FileManager.default.removeItem(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]))
            } catch {
                extern_deeplog("KERNEL I/O: \(error)")
            }
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_WR")
        }
    }
    let fs_touch: @convention(block) (String?,String?) -> Void = { rawpath,content in
        let path = chdir_path(path: rawpath, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isWritable(path: path) {
            FileManager.default.createFile(atPath: ssdlise_path(path: path, cwd: process.envp["pwd"]), contents: Data((content ?? "").utf8))
        } else {
            warnthekernel(process: process.pid, callname: "SYS_FS_WR")
        }
    }
    let fs_chdir: @convention(block) (String) -> Void = { path in
        let tempdir = chdir_path(path: path, cwd: process.envp["pwd"])
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: ssdlise_path(path: "", cwd: tempdir), isDirectory: &isDir), isDir.boolValue {
            process.envp["pwd"] = tempdir
        }
    }
    
    // DEBUG!
    let fs_chown: @convention(block) (String, UInt16) -> Void = { path, uid in
        let tempdir = chdir_path(path: path, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isWritable(path: tempdir) {
            let wener: UInt16 = kernel_proc.piduid(ofpid: process.pid)
            if kernel_fs.isRegistered(path: tempdir) {
                let owner: UInt16 = kernel_fs.getOwner(path: tempdir)
                if owner >= wener, uid >= wener {
                    kernel_fs.setOwner(path: tempdir, value: uid)
                }
            } else {
                if uid >= wener {
                    kernel_fs.append(path: tempdir, perm:[0x01,0x01,0x00])
                    kernel_fs.setOwner(path: tempdir, value: uid)
                }
            }
        }
    }
    let fs_chgrp: @convention(block) (String, UInt16) -> Void = { path, uid in
        let tempdir = chdir_path(path: path, cwd: process.envp["pwd"])
        if kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isWritable(path: tempdir) {
            let wener: UInt16 = kernel_proc.pidgid(ofpid: process.pid)
            if kernel_fs.isRegistered(path: tempdir) {
                let group: UInt16 = kernel_fs.getGroup(path: tempdir)
                if group >= wener, uid >= wener {
                    kernel_fs.setGroup(path: tempdir, value: uid)
                }
            } else {
                if uid >= wener {
                    kernel_fs.append(path: tempdir, perm:[0x01,0x01,0x00])
                    kernel_fs.setGroup(path: tempdir, value: uid)
                }
            }
        }
    }
    let fs_getown: @convention(block) (String) -> UInt16 = { path in
        let tempdir = chdir_path(path: path, cwd: process.envp["pwd"])
        if FileManager.default.fileExists(atPath: "\(JSTermRoot)/\(tempdir)"), kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isReadable(path: tempdir) {
            return kernel_fs.getOwner(path: tempdir)
        }
        return 0
    }
    let fs_getgrp: @convention(block) (String) -> UInt16 = { path in
        let tempdir = chdir_path(path: path, cwd: process.envp["pwd"])
        if FileManager.default.fileExists(atPath: tempdir), kernel_proc.hasperm(ofpid: process.pid, call: SYS_FS_WR) == 0, kernel_fs.isReadable(path: tempdir) {
            return kernel_fs.getGroup(path: tempdir)
        }
        return 0
    }
    
    ld_add_symbol(symbol: fs_validate, name: "fs_validate", process: process)
    ld_add_symbol(symbol: fs_list, name: "fs_list", process: process)
    ld_add_symbol(symbol: fs_read, name: "fs_read", process: process)
    ld_add_symbol(symbol: fs_write, name: "fs_write", process: process)
    ld_add_symbol(symbol: fs_remove, name: "fs_remove", process: process)
    ld_add_symbol(symbol: fs_mkdir, name: "mkdir", process: process)
    ld_add_symbol(symbol: fs_rmdir, name: "rmdir", process: process)
    ld_add_symbol(symbol: fs_rmdir, name: "rm", process: process)
    ld_add_symbol(symbol: fs_touch, name: "touch", process: process)
    ld_add_symbol(symbol: fs_chdir, name: "chdir", process: process)
    
    // DEBUG!
    ld_add_symbol(symbol: fs_chown, name: "chown", process: process)
    ld_add_symbol(symbol: fs_chgrp, name: "chgrp", process: process)
    ld_add_symbol(symbol: fs_getown, name: "getown", process: process)
    ld_add_symbol(symbol: fs_getgrp, name: "getgrp", process: process)
}
