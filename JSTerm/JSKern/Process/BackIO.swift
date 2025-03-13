//
//  BackIO.swift
//  JSTerm
//
//  Created by fridakitten on 13.03.25.
//

import Foundation

@objc class BackIO: NSObject {
    @objc func osprint(msg: String)
    {
        extern_deeplog(msg)
    }
}
