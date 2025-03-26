//
//  Main.swift
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

import SwiftUI
import UIKit
import Foundation

@main
struct JSTermApp: App {
    init() {
        handoffMachine()
    }
    var body: some Scene {
        WindowGroup {
            TerminalWindow()
        }
    }
}
