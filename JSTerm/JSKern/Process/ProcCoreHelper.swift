//
//  LibProcCore.swift
//  JSTerm
//
//  Created by fridakitten on 11.03.25.
//

import Foundation

@objc class proccorehelper: NSObject {
    var proc: [UInt16:UnsafeMutablePointer<pthread_t>] = [:]
    
    @objc func assignThread(pid: UInt16, thread: UnsafeMutablePointer<pthread_t>) {
        proc[pid] = thread
    }
    
    @objc func getThread(pid: UInt16) -> UnsafeMutablePointer<pthread_t>? {
        return proc[pid]
    }
}
