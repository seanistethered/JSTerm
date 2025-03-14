/*
TerminalView.swift
 
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

import SwiftUI
import UIKit

var TerminalWindows: [TerminalWindow] = []

var setcolor: (Color) -> Void = { color in  }

struct RootTerminalViewSub: UIViewRepresentable {
    var rootView: TerminalWindow
    
    init(rootView: TerminalWindow) {
        self.rootView = rootView
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let terminalView = rootView
        terminalView.frame = view.bounds
        terminalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(terminalView)
        
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

var refreshcolor: () -> Void = {}
struct RootTerminalView: View, Identifiable, Hashable {
    var id: UUID = UUID()
    var rootView: TerminalWindow
    @State var color: Color = Color.clear
    
    init(rootView: TerminalWindow) {
        self.id = UUID()
        self.rootView = rootView
    }
    
    var body: some View {
        ZStack {
            color
                .ignoresSafeArea(.all)
            RootTerminalViewSub(rootView: rootView)
        }
        .onAppear {
            color = Color(rootView.terminalText.backgroundColor ?? UIColor.clear)
            refreshcolor = {
                self.color = Color(rootView.terminalText.backgroundColor ?? UIColor.clear)
            }
        }
    }
    
    static func == (lhs: RootTerminalView, rhs: RootTerminalView) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class TerminalWindow: UIView, UITextViewDelegate {
    let id: UUID = UUID()
    var terminalText: UITextView = UITextView()
    var capturedInput: String = ""
    var input: (String) -> Void = { _ in }
    var deletion: (String) -> Void = { _ in }
    var refreshcolor: (Color) -> Void = { color in }
    var name: String = "Serial"

    func setInput(new: @escaping (String) -> Void) {
        input = new
    }

    func setDeletion(new: @escaping (String) -> Void) {
        deletion = new
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        terminalText.frame = self.bounds
        terminalText.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        terminalText.text = ""
        terminalText.backgroundColor = .clear
        terminalText.isEditable = true
        terminalText.font = UIFont.monospacedSystemFont(ofSize: 10.0, weight: .semibold)
        terminalText.delegate = self
        terminalText.keyboardType = .asciiCapable
        terminalText.textContentType = .none
        terminalText.smartQuotesType = .no
        terminalText.smartDashesType = .no
        terminalText.smartInsertDeleteType = .no
        terminalText.autocorrectionType = .no
        terminalText.autocapitalizationType = .none
        //terminalText.layoutManager.allowsNonContiguousLayout = true
        terminalText.layer.shouldRasterize = true
        terminalText.layer.rasterizationScale = UIScreen.main.scale
        terminalText.isUserInteractionEnabled = true
        //terminalText.layoutManager.addTextContainer(terminalText.textContainer)
        //terminalText.layoutManager.ensureLayout(for: terminalText.textContainer)
        terminalText.isUserInteractionEnabled = false
        self.addSubview(terminalText)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
        if string.isEmpty {
            deletion(string)
        } else {
            input(string)
        }
        return false
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            DispatchQueue.main.async {
                self.terminalText.becomeFirstResponder()
            }
        }
    }
}
