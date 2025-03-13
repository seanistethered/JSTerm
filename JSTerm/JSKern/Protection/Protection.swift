//
//  Protection.swift
//  JSTerm
//
//  Created by fridakitten on 13.03.25.
//

import Foundation

/*
 @Brief class for protection
 */
class jskern_protection_class {
    let thread: DispatchQueue = DispatchQueue(label: "\(UUID())")
    
    /*
     @Brief functions to take a bit work away from the FS API and harden the security a bit
     */
    func canReadQuestion(pid: UInt16, path: String) -> Bool
    {
        let uid: UInt16 = kernel_proc.piduid(ofpid: pid)
        let gid: UInt16 = kernel_proc.pidgid(ofpid: pid)
        if kernel_proc.hasperm(ofpid: pid, call: SYS_FS_RD) == 0 {
            let perm = kernel_fs.fs_treepermcheck(path: path, uid: uid, gid: gid)
            if perm.canRead {
                return true
            }
        }
        return false
    }
    func canWriteQuestion(pid: UInt16, path: String) -> Bool
    {
        let uid: UInt16 = kernel_proc.piduid(ofpid: pid)
        let gid: UInt16 = kernel_proc.pidgid(ofpid: pid)
        if kernel_proc.hasperm(ofpid: pid, call: SYS_FS_WR) == 0 {
            let perm = kernel_fs.fs_treepermcheck(path: path, uid: uid, gid: gid)
            if perm.canWrite {
                return true
            }
        }
        return false
    }
    func canExecuteQuestion(pid: UInt16, path: String) -> Bool
    {
        let uid: UInt16 = kernel_proc.piduid(ofpid: pid)
        let gid: UInt16 = kernel_proc.pidgid(ofpid: pid)
        if kernel_proc.hasperm(ofpid: pid, call: SYS_EXEC) == 0 {
            let perm = kernel_fs.fs_treepermcheck(path: path, uid: uid, gid: gid)
            if perm.canExecute {
                return true
            }
        }
        return false
    }
}
