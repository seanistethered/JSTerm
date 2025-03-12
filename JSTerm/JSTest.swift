/*
JSTest.swift
 
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

struct TileButtonStyle: ButtonStyle {
    var isSelected: Bool
    var doColor: Color
    
    init(isSelected: Bool, doColor: Color = Color.blue) {
        self.isSelected = isSelected
        self.doColor = doColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? doColor.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? doColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct TileToolbar: View {
    @Binding var windows: [TerminalWindow]
    @Binding var active: RootTerminalView
    @Binding var activeid: UUID
    @Binding var activeBar: Bool
    
    @State var activeFSView: Bool = false
    @State var activeSettings: Bool = false
    
    @State private var actpath: String = ""
    @State private var actint: Int = 0
    
    var body: some View {
        HStack {
            Spacer().frame(width: 0, height: 0)
            .padding(.horizontal, 1)
            Button(action: {
                activeFSView = true
            }) {
                Image(systemName: "internaldrive.fill")
            }
            .buttonStyle(TileButtonStyle(isSelected: true, doColor: Color.yellow))
            .padding(.horizontal, 1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(windows, id: \.self) { item in
                        Button(action: {
                            withAnimation {
                                active = RootTerminalView(rootView: item)
                                activeid = UUID()
                                activeBar = !activeBar
                            }
                        }) {
                            Text(item.name)
                                .font(.system(size: 12))
                                .id(activeid)
                        }
                        .buttonStyle(TileButtonStyle(isSelected: active.rootView == item))
                    }
                }
                .padding(.horizontal, 1)
                .padding(.vertical, 8)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
        .opacity(activeBar ? 1.0 : 0.0)
        .sheet(isPresented: $activeFSView) {
            NavigationView {
                List {
                    NavigationLink(destination: FileList(title: "KernelFS",directoryPath: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/kernelfs"), actpath: $actpath, action: $actint)) {
                        Label("KernelFS", systemImage: "internaldrive.fill")
                    }
                    NavigationLink(destination: FileList(title: "RootFS",directoryPath: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/rootfs"), actpath: $actpath, action: $actint)) {
                        Label("RootFS", systemImage: "internaldrive.fill")
                    }
                }
                .navigationTitle("Disks")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                activeSettings = true
                            }
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            format()
                            exit(0)
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .accentColor(.primary)
        }
        .sheet(isPresented: $activeSettings) {
            NeoEditorSettings()
        }
    }
}

struct ContentView: View {
    @State private var terminalViews: [TerminalWindow] = []
    
    @State private var active: RootTerminalView = RootTerminalView(rootView: TerminalWindow())
    @State private var activeid: UUID = UUID()
    @State private var activeBar: Bool = false

    var body: some View {
        ZStack {
            // Display the active TerminalWindow
            VStack {
                active
                    .id(activeid)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            activeBar = !activeBar
                        }
                    }
            }
        
            //if activeBar {
                VStack {
                    Spacer()
                        .frame(height: 40)
                    TileToolbar(windows: $terminalViews, active: $active, activeid: $activeid, activeBar: $activeBar)
                    Spacer()
                }
                .ignoresSafeArea(.all)
            //}
        }
        .onAppear {
            format()
            refresh = {
                terminalViews = TerminalWindows
                if !terminalViews.contains(active.rootView) {
                    active = RootTerminalView(rootView: terminalViews[0])
                    activeid = UUID()
                }
            }
            DispatchQueue.global(qos: .utility).async {
                DispatchQueue.main.sync {
                    TerminalWindows.append(TerminalWindow())
                    TerminalWindows[0].name = "Kernel Land Serial"
                }
                _ = JavaScriptInit(terminal: TerminalWindows[0])
                refresh()
                active = RootTerminalView(rootView: terminalViews[0])
            }
        }
    }
}

