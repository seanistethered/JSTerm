/*
JSTermApp.swift
 
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

func format() {
    var version: UInt64 = 0
    if FileManager.default.fileExists(atPath: "\(NSHomeDirectory())/Documents/rootfs/.installed_frida") {
        if let content = FileManager.default.contents(atPath: "\(NSHomeDirectory())/Documents/rootfs/.installed_frida") {
            if let content = String(data: content, encoding: .utf8) {
                version = UInt64(content) ?? 0
            }
        }
    }
    if version != 5 {
        // FS
        do {
            try clearContentsOfFolder(atPath: "\(NSHomeDirectory())/Documents")
            try FileManager.default.createDirectory(atPath: "\(NSHomeDirectory())/Documents/rootfs", withIntermediateDirectories: false)
            try FileManager.default.createDirectory(atPath: "\(NSHomeDirectory())/Documents/rootfs/etc", withIntermediateDirectories: false)
            try FileManager.default.createDirectory(atPath: "\(NSHomeDirectory())/Documents/rootfs/bin", withIntermediateDirectories: false)
            try FileManager.default.createDirectory(atPath: "\(NSHomeDirectory())/Documents/rootfs/sbin", withIntermediateDirectories: false)
            try FileManager.default.createDirectory(atPath: "\(NSHomeDirectory())/Documents/rootfs/games", withIntermediateDirectories: false)
            try FileManager.default.createDirectory(atPath: "\(NSHomeDirectory())/Documents/kernelfs", withIntermediateDirectories: false)
        } catch {}
        
        let etcstack: [String] = [
            "host.etc"
        ]
        let sbinstack: [String] = [
            "shell.js",
            "mkdir.js",
            "rmdir.js",
            "uname.js",
            "ls.js",
            "env.js",
            "mkserial.js",
            "hostname.js",
            "su.js",
            "whoami.js",
            "id.js",
            "ps.js",
            "chown.js",
            "cat.js",
            "shutdown.js",
            "kill.js",
            "pamctl.js",
            "serialctl.js",
            "mv.js"
        ]
        let gamesstack: [String] = [
            "2048.js",
            "snake.js"
        ]
        let stack: [String] = FindFilesStack("\(Bundle.main.bundlePath)", ["js", "env"], [])
        for item in stack {
            if sbinstack.contains(item) {
                copyf(sourcePath: "\(Bundle.main.bundlePath)/\(item)", destinationPath: "\(NSHomeDirectory())/Documents/rootfs/sbin/\(item)")
            } else if gamesstack.contains(item) {
                copyf(sourcePath: "\(Bundle.main.bundlePath)/\(item)", destinationPath: "\(NSHomeDirectory())/Documents/rootfs/games/\(item)")
            } else {
                copyf(sourcePath: "\(Bundle.main.bundlePath)/\(item)", destinationPath: "\(NSHomeDirectory())/Documents/rootfs/bin/\(item)")
            }
        }
        
        // etc build
        copyf(sourcePath: "\(Bundle.main.bundlePath)/host.etc", destinationPath: "\(NSHomeDirectory())/Documents/rootfs/etc/host")
        
        // USR
        do {
            try saveusrfile([0:"root"], to: URL(fileURLWithPath: "\(JSTermKernel)/user"))
            try saveusrfile([0:"alpine"], to: URL(fileURLWithPath: "\(JSTermKernel)/passwd"))
            try savesyscallfile([0:[SYS_SETUID, SYS_SETGID, SYS_USRMGR, SYS_FS_WR, SYS_FS_RD, SYS_EXEC, SYS_SYSCTL]], to: URL(fileURLWithPath: "\(JSTermKernel)/syscall"))
        } catch {}
        
        FileManager.default.createFile(atPath: "\(NSHomeDirectory())/Documents/rootfs/.installed_frida", contents: Data("5".utf8))
    }
}

var refresh: () -> Void = {}

struct TerminalFinalView: View {
    var daddy: RootTerminalView
    
    var body: some View {
        daddy
            .navigationTitle(daddy.rootView.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct SerialList: View {
    @State private var actpath: String = ""
    @State private var actint: Int = 0
    @State private var show: Bool = false
    @State private var labelid: UUID = UUID()
    
    @State private var winarray: [TerminalWindow] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Serials")) {
                    ForEach(winarray, id: \.self) { item in
                        NavigationLink(destination: TerminalFinalView(daddy: RootTerminalView(rootView: item))) {
                            Label(item.name, systemImage: "apple.terminal.fill")
                                .id(labelid)
                        }
                    }
                }
                Section(header: Text("SATA")) {
                    NavigationLink(destination: FileList(title: "KernelFS",directoryPath: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/kernelfs"), actpath: $actpath, action: $actint)) {
                        Label("KernelFS", systemImage: "internaldrive.fill")
                    }
                    NavigationLink(destination: FileList(title: "RootFS",directoryPath: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/rootfs"), actpath: $actpath, action: $actint)) {
                        Label("RootFS", systemImage: "internaldrive.fill")
                    }
                }
                .contextMenu {
                    Button(role: .destructive, action: {
                        format()
                    }) {
                        Label("Format", systemImage: "trash.fill")
                    }
                }
            }
            .navigationTitle("JSTerm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        show = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if FileManager.default.fileExists(atPath: JSTermRoot) {
                            refresh = {
                                winarray = TerminalWindows
                                labelid = UUID()
                            }
                            DispatchQueue.global(qos: .utility).async {
                                DispatchQueue.main.sync {
                                    TerminalWindows.append(TerminalWindow())
                                    TerminalWindows[0].name = "Kernel Land Serial"
                                }
                                _ = JavaScriptInit(terminal: TerminalWindows[0])
                                refresh()
                            }
                        } else {
                            format()
                            refresh = {
                                winarray = TerminalWindows
                            }
                            DispatchQueue.global(qos: .utility).async {
                                DispatchQueue.main.sync {
                                    TerminalWindows.append(TerminalWindow())
                                    TerminalWindows[0].name = "Kernel Land Serial"
                                }
                                _ = JavaScriptInit(terminal: TerminalWindows[0])
                                refresh()
                            }
                        }
                    }) {
                        Image(systemName: "bolt.fill")
                    }
                    .disabled(TerminalWindows.isEmpty ? false : true)
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
        .sheet(isPresented: $show) {
            NeoEditorSettings()
        }
    }
}

@main
struct JSTermApp: App {
    init() {
        UIInit(type: 1)
    }
    
    var body: some Scene {
        WindowGroup {
            //SerialList()
            ContentView()
        }
    }
}
