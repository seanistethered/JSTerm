//
//  Representables.swift
//  JSTerm
//
//  Created by fridakitten on 14.03.25.
//

import Foundation
import SwiftUI
import UIKit

struct TerminalWindow: UIViewRepresentable {
    @State var object: TerminalView
    
    init() {
        self.object = handoffUI()
    }
    
    // Create the TerminalView instance
    func makeUIView(context: Context) -> TerminalView {
        let view = self.object
        return object
    }
    
    func updateUIView(_ uiView: TerminalView, context: Context) {}
}

