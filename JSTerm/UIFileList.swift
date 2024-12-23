/*
UIFileList.swift
 
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
import Foundation
import UniformTypeIdentifiers

private let invalidFS: Set<Character> = ["/", "\\", ":", "*", "?", "\"", "<", ">", "|"]

private enum ActiveSheet: Identifiable {
   case create, rename, remove

   var id: Int {
       hashValue
   }
}

struct FileProperty {
   var symbol: String
   var color: Color
   var size: Int
}

struct FileObject: View {
   var properties: FileProperty
   var item: URL
   var body: some View {
       HStack {
           HStack {
               ZStack {
                   Image(systemName: "doc.fill")
                       .foregroundColor(properties.color)
                   VStack {
                       Spacer().frame(height: 8)
                       Text(properties.symbol)
                           .font(.system(size: CGFloat(properties.size), weight: .bold))
                           .foregroundColor(Color(.systemBackground))
                   }
               }
               Text(item.lastPathComponent)
               Spacer()
                   Text("\(gfilesize(atPath: item.path))")
                       .font(.system(size: 10, weight: .semibold))
           }
       }
   }
}

struct FileList: View {
   var title: String?
   var directoryPath: URL
   @State private var activeSheet: ActiveSheet?
   @State private var files: [URL] = []
   @State private var quar: Bool = false
   @State private var selpath: String = ""
   @State private var fbool: Bool = false
   var buildv: Binding<Bool>?
   @Binding var actpath: String
   @Binding var action: Int

   @State private var poheader: String = ""
   @State private var potextfield: String = ""
   @State private var type: Int = 0

   @State private var macros: [String] = []
   @State private var cmacro: String = ""

   // GitHub
   @AppStorage("GIT_ENABLED") var enabled: Bool = false
   @AppStorage("GIT_TOKEN") var token: String = ""
   var body: some View {
       List {
           Section {
               ForEach(files, id: \.self) { item in
                   HStack {
                       if isDirectory(item) {
                           NavigationLink(destination: FileList(title: nil, directoryPath: item, actpath: $actpath, action: $action)) {
                               HStack {
                                   Image(systemName: "folder.fill")
                                       .foregroundColor(.primary)
                                   Text(item.lastPathComponent)
                               }
                           }
                       } else {
                           Button(action: {
                               selpath = item.path
                               if !gtypo(item: item.lastPathComponent) {
                                   quar = true
                               } else {
                                   fbool = true
                               }
                           }) {
                               FileObject(properties: gProperty(item), item: item)
                           }
                       }
                   }
                   .contextMenu {
                       Section {
                           Button(action: {
                               selpath = item.lastPathComponent
                               potextfield = selpath
                               activeSheet = .rename
                           }) {
                               Label("Rename", systemImage: "pencil")
                           }
                       }
                       Section {
                           Button(action: {
                               actpath = item.path
                               action = 1
                           }) {
                               Label("Copy", systemImage: "doc.on.doc.fill")
                           }
                           Button(action: {
                               actpath = item.path
                               action = 2
                           }) {
                               Label("Move", systemImage: "folder.fill")
                           }
                       }
                       Section {
                           Button( action: {
                               share(url: item, remove: false)
                           }) {
                               Label("Share", systemImage: "square.and.arrow.up.fill")
                           }
                       }
                       Section {
                           Button(role: .destructive, action: {
                               selpath = item.path
                               activeSheet = .remove
                               poheader = "Remove \"\(item.lastPathComponent)\"?"
                           }) {
                               Label("Remove", systemImage: "trash.fill")
                           }
                       }
                   }
               }
           }
       }
       .refreshable {
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
               withAnimation {
                   files = []
               }
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                   bindLoadFiles(directoryPath: directoryPath, files: $files)
               }
           }
       }
       .onAppear {
           bindLoadFiles(directoryPath: directoryPath, files: $files)
       }
       .listStyle(InsetGroupedListStyle())
       .navigationTitle(
           title ?? directoryPath.lastPathComponent
       )
       .navigationBarTitleDisplayMode(.inline)
       .toolbar {
           ToolbarItem(placement: .navigationBarTrailing) {
               Menu {
                   if let buildv = buildv {
                       Section {
                           Button(action: {
                               buildv.wrappedValue = true
                           }) {
                               Label("Build", systemImage: "play.fill")
                           }
                       }
                   }
                   Section {
                       Button(action: { activeSheet = .create }) {
                           Label("Create", systemImage: "doc.fill.badge.plus")
                       }
                   }
                   if action > 0 {
                       Section {
                           Button(action: {
                               if action == 1 {
                                   _ = cp(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
                                   action = 0
                               } else if action == 2 {
                                   _ = mv(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
                                   action = 0
                               }
                               //haptfeedback(1)
                               bindLoadFiles(directoryPath: directoryPath, files: $files)
                           }) {
                               Label("Paste", systemImage: "doc.on.clipboard")
                           }
                       }
                   }
               } label: {
                   Label("", systemImage: "ellipsis.circle")
               }
           }
       }
       .sheet(item: $activeSheet) { sheet in
           Group {
               BottomPopupView {
                   switch sheet {
                   case .create:
                       POHeader(title: "Create")
                       POTextField(title: "Filename", content: $potextfield)
                       POPicker(function: create_selected, title: "Type", arrays: [PickerArrays(title: "Type", items: [PickerItems(id: 0, name: "File"), PickerItems(id: 1, name: "Folder")])], type: $type)
                   case .rename:
                       POHeader(title: "Rename")
                       POTextField(title: "Filename", content: $potextfield)
                       POButtonBar(cancel: dissmiss_sheet, confirm: rename_selected)
                   case .remove:
                       POBHeader(title: $poheader)
                       Spacer().frame(height: 10)
                       POButtonBar(cancel: dissmiss_sheet, confirm: remove_selected)
                   default:
                       Spacer()
                   }
               }
           }
           .background(BackgroundClearView())
           .edgesIgnoringSafeArea([.bottom])
           .onDisappear {
               poheader = ""
               potextfield = ""
               bindLoadFiles(directoryPath: directoryPath, files: $files)
           }
       }
       .fullScreenCover(isPresented: $quar) {
           NeoEditorHelper(isPresented: $quar, filepath: $selpath)
       }
       .fullScreenCover(isPresented: $fbool) {
           ImageView(imagePath: $selpath, fbool: $fbool)
       }
   }

   private func create_selected() -> Void {
       if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
           if type == 0 {
           var content = ""
               switch gsuffix(from: potextfield) {
                   case "swift", "c", "m", "mm", "cpp", "h", "hpp", "js":
                       content = authorgen(file: potextfield)
                       break
                   default:
                       break
               }
               cfile(atPath: "\(directoryPath.path)/\(potextfield)", withContent: content)
           } else {
               cfolder(atPath: "\(directoryPath.path)/\(potextfield)")
           }
           //haptfeedback(1)
           activeSheet = nil
       } else {
           //haptfeedback(2)
       }
   }

   private func rename_selected() -> Void {
       if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
           _ = mv("\(directoryPath.path)/\(selpath)", "\(directoryPath.path)/\(potextfield)")
           //haptfeedback(1)
           activeSheet = nil
       } else {
           //haptfeedback(2)
       }
   }

   private func remove_selected() -> Void {
       _ = rm(selpath)
       //haptfeedback(1)
       activeSheet = nil
   }

   private func dissmiss_sheet() -> Void {
       activeSheet = nil
   }

   private func gtypo(item: String) -> Bool {
       let suffix = gsuffix(from: item)
       switch(suffix) {
           case "png", "jpg", "jpeg", "PNG", "JPG":
               return true
           default:
               return false
       }
   }
}

struct ImageView: View {
   @Binding var imagePath: String
   @Binding var fbool: Bool

   init(imagePath: Binding<String>, fbool: Binding<Bool>) {
       _imagePath = imagePath
       _fbool = fbool
       UIInit(type: 1)
   }

   var body: some View {
       NavigationView {
           ZStack {
               Color(UIColor.systemGray6)
                   .ignoresSafeArea()
               VStack {
                   Image(uiImage: loadImage())
                       .resizable()
                       .scaledToFit()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: UIScreen.main.bounds.width)
               }
               .navigationBarTitle("Image Viewer", displayMode: .inline)
               .navigationBarItems(leading:
                   Button(action: {
                       UIInit(type: 0)
                       fbool = false
                   }) {
                       Text("Close")
                   }
               )
           }
       }
   }

   private func loadImage() -> UIImage {
       guard let image = UIImage(contentsOfFile: imagePath) else {
           return UIImage(systemName: "photo")!
       }
       return image
   }
}

struct SDKList: View {
   @State private var files: [URL] = []
   @State var directoryPath: URL
   @Binding var sdk: String
   @Binding var isActive: Bool
   var body: some View {
       List {
           Section {
               ForEach(files, id: \.self) { folder in
                   Button( action: {
                       sdk = folder.lastPathComponent
                       isActive = false
                   }){
                       HStack {
                           Image(systemName: "sdcard.fill")
                           Text(folder.lastPathComponent)
                       }
                   }
               }
           }
       }
       .onAppear {
           bindLoadFiles(directoryPath: directoryPath, files: $files)
       }
       .accentColor(.primary)
       .listStyle(InsetGroupedListStyle())
       .navigationTitle("SDKs")
       .navigationBarTitleDisplayMode(.inline)
   }
}

private func gfilesize(atPath filePath: String) -> String {
   let fileURL = URL(fileURLWithPath: filePath)

   do {
       let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)

       if let fileSize = attributes[FileAttributeKey.size] as? Int64 {
           let fileSizeInBytes = Double(fileSize)
           let units = ["B", "KB", "MB", "GB", "TB"]
           var unitIndex = 0
           var adjustedSize = fileSizeInBytes

           while adjustedSize >= 1024 && unitIndex < units.count - 1 {
               adjustedSize /= 1024
               unitIndex += 1
           }

           return String(format: "%.2f %@", adjustedSize, units[unitIndex])
       } else {
           return "0.00 B"
       }
   } catch {
       return "0.00 B"
   }
}


func isDirectory(_ url: URL) -> Bool {
   var isDir: ObjCBool = false
   return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
}

private func gProperty(_ fileURL: URL) -> FileProperty {
   var property: FileProperty = FileProperty(symbol: "", color: Color.black, size: 0)

   let suffix = gsuffix(from: fileURL.path)
   switch(suffix) {
       case "m":
           property.symbol = "m"
           property.color = Color.orange
           property.size = 8
       case "js":
           property.symbol = "js"
           property.color = Color.orange
           property.size = 5
       case "c":
           property.symbol = "c"
           property.color = Color.blue
           property.size = 8
       case "mm":
           property.symbol = "mm"
           property.color = Color.yellow
           property.size = 5
       case "cpp":
           property.symbol = "cpp"
           property.color = Color.green
           property.size = 4
       case "hpp":
           property.symbol = "hpp"
           property.color = Color.secondary
           property.size = 4
       case "swift":
           property.color = Color.red
       case "h":
           property.symbol = "h"
           property.color = Color.secondary
           property.size = 8
       case "api":
           property.symbol = "api"
           property.color = Color.purple
           property.size = 4
       default:
           property.color = Color.primary
   }

   return property
}

private func bindLoadFiles(directoryPath: URL, files: Binding<[URL]>) -> Void {
   let fileManager = FileManager.default

   DispatchQueue.global(qos: .background).async {
       do {
           let items = try fileManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)

           var fileGroups: [String: [URL]] = [:]

           for item in items {
               let fileExtension = item.pathExtension.lowercased()
               if !isDirectory(item) {
                   if fileGroups[fileExtension] == nil {
                       fileGroups[fileExtension] = []
                   }
                   fileGroups[fileExtension]?.append(item)
               }
           }

           DispatchQueue.main.async {
               withAnimation {
                   files.wrappedValue.removeAll { file in
                       !fileManager.fileExists(atPath: file.path)
                   }
               }
           }

           for item in items {
               if isDirectory(item) {
                   DispatchQueue.main.async {
                       if !files.wrappedValue.contains(item) {
                           withAnimation {
                               files.wrappedValue.append(item)
                           }
                       }
                   }
                   usleep(500)
               }
           }

           for (_, groupedFiles) in fileGroups.sorted(by: { $0.key < $1.key }) {
               for file in groupedFiles {
                   DispatchQueue.main.async {
                       if !files.wrappedValue.contains(file) {
                           withAnimation {
                               files.wrappedValue.append(file)
                           }
                       }
                   }
                   usleep(500)
               }
           }

       } catch {
           DispatchQueue.main.async {
               print("Error loading files: \(error.localizedDescription)")
           }
       }
   }
}

struct DocumentPicker: UIViewControllerRepresentable {
   @State var pathURL: URL
   @Environment(\.presentationMode) private var presentationMode

   func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
       let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
       documentPicker.allowsMultipleSelection = true
       documentPicker.delegate = context.coordinator
       return documentPicker
   }

   func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

   func makeCoordinator() -> Coordinator {
       return Coordinator(self)
   }

   class Coordinator: NSObject, UIDocumentPickerDelegate {
       let parent: DocumentPicker

       init(_ parent: DocumentPicker) {
           self.parent = parent
       }

       func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
           for item in urls {
               _ = mv(item.path, "\(parent.pathURL.path)/\(item.lastPathComponent)")
           }
           parent.presentationMode.wrappedValue.dismiss()
       }

       func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
           parent.presentationMode.wrappedValue.dismiss()
       }
   }
}

func share(url: URL, remove: Bool = false) -> Void {
    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    activityViewController.modalPresentationStyle = .popover
        if remove {
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
            }
        }
    }

    DispatchQueue.main.async {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootViewController = windowScene.windows.first?.rootViewController {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = rootViewController.view
                    popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                      y: rootViewController.view.bounds.midY,
                                                      width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                rootViewController.present(activityViewController, animated: true, completion: nil)
            } else {
                print("No root view controller found.")
            }
        } else {
            print("No window scene found.")
        }
    }
}

import Foundation

func cfolder(atPath path: String) -> Void {
   do {
       try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
   } catch {
       print("Error creating folder: \(error)")
   }
}

func cfile(atPath path: String, withContent content: String) -> Void {
   do {
       try content.write(toFile: path, atomically: true, encoding: .utf8)
       print("File created successfully at path: \(path)")
   } catch {
       print("Error creating file: \(error.localizedDescription)")
   }
}

func copyf(sourcePath: String, destinationPath: String) -> Void {
   do {
       try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
   } catch {
       print("Error creating file: \(error.localizedDescription)")
   }
}

func copyc(from sp: String, to dp: String) throws {
   let sourcePath = sp
   let destinationPath = dp

   let fileManager = FileManager.default
   
   // Check if the source path exists
   guard fileManager.fileExists(atPath: sourcePath) else {
       throw NSError(domain: "CopyContentsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Source path not found"])
   }
   
   // Check if the destination path exists, create it if not
   if !fileManager.fileExists(atPath: destinationPath) {
       try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
   }
   
   // Get contents of the source path
   let contents = try fileManager.contentsOfDirectory(atPath: sourcePath)
   
   // Copy each item to the destination path
   for item in contents {
       let sourceItemPath = (sourcePath as NSString).appendingPathComponent(item)
       let destinationItemPath = (destinationPath as NSString).appendingPathComponent(item)
       
       try fileManager.copyItem(atPath: sourceItemPath, toPath: destinationItemPath)
   }
}

func renameFile(atPath filePath: String, to newFileName: String) throws {
   let directoryPath = (filePath as NSString).deletingLastPathComponent
   let newFilePath = (directoryPath as NSString).appendingPathComponent(newFileName)
   try FileManager.default.moveItem(atPath: filePath, toPath: newFilePath)
}

func adv_rm(atPath path: String) throws {
   let protectedPaths: Set<String> = ["/", "/System", "/bin", "/sbin", "/usr", "/etc", "/var"]
   let normalizedPath = URL(fileURLWithPath: path).standardized.path
   
   guard !protectedPaths.contains(normalizedPath) else {
       throw NSError(domain: "com.example.FileManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Attempted to remove contents from a protected system path: \(path)"])
   }

   let fileManager = FileManager.default
   let contents = try fileManager.contentsOfDirectory(atPath: normalizedPath)
   
   for item in contents {
       let itemPath = normalizedPath + "/" + item
       do {
           try fileManager.removeItem(atPath: itemPath)
       } catch {
           throw error
       }
   }
}

@discardableResult func rm(_ path: String) -> Int {
   let fileManager = FileManager.default
   if fileManager.fileExists(atPath: path) {
       do {
           try fileManager.removeItem(atPath: path)
       } catch {
           return 2
       }
   } else {
       return 1
   }
   return 0
}

@discardableResult func mv(_ fromPath: String, _ toPath: String) -> Int {
   let fileManager = FileManager.default
   if fileManager.fileExists(atPath: fromPath) {
       do {
           try fileManager.moveItem(atPath: fromPath, toPath: toPath)
       } catch {
           return 2
       }
   } else {
       return 1
   }
   return 0
}

@discardableResult func cp(_ sourcePath: String,_ destinationPath: String) -> Int {
   let fileManager = FileManager.default
   
   do {
       guard fileManager.fileExists(atPath: sourcePath) else {
           return 1
       }
       
       if fileManager.fileExists(atPath: destinationPath) {
           try fileManager.removeItem(atPath: destinationPath)
       }
       
       try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
       
       return 0
   } catch {
       return 1
   }
}

struct BackgroundClearView: UIViewRepresentable {
   func makeUIView(context: Context) -> UIView {
       let view = UIView()

       DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
           view.superview?.superview?.backgroundColor = .clear
       }

       return view
   }

   func updateUIView(_ uiView: UIView, context: Context) {}
}

func authorgen(file: String) -> String {
    let author = UserDefaults.standard.string(forKey: "Author")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yy"
    let currentDate = Date()
    return "//\n// \(file)\n//\n// Created by \(author ?? "Anonym") on \(dateFormatter.string(from: currentDate))\n//\n \n"
}

func UIInit(type: Int) -> Void {
    switch type {
        case 0:
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = UIColor.systemBackground
            let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            navigationBarAppearance.titleTextAttributes = titleAttributes
            let buttonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes
            let backItemAppearance = UIBarButtonItemAppearance()
            backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.label]
            navigationBarAppearance.backButtonAppearance = backItemAppearance
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            return
        case 1:
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            return
        default:
            return
    }
}

func clearContentsOfFolder(atPath folderPath: String) throws {
    let fileManager = FileManager.default

    // Check if the folder exists
    guard fileManager.fileExists(atPath: folderPath) else {
        throw NSError(domain: "FolderNotFoundError", code: 1, userInfo: [NSLocalizedDescriptionKey: "The folder does not exist at path: \(folderPath)"])
    }

    // Get the contents of the folder
    let contents = try fileManager.contentsOfDirectory(atPath: folderPath)

    for item in contents {
        let fullPath = (folderPath as NSString).appendingPathComponent(item)
        var isDirectory: ObjCBool = false

        // Check if the item is a directory
        if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                // Remove the directory and its contents
                try fileManager.removeItem(atPath: fullPath)
            } else {
                // Remove the file
                try fileManager.removeItem(atPath: fullPath)
            }
        }
    }
}

func FindFilesStack(_ projectPath: String, _ fileExtensions: [String], _ ignore: [String]) -> [String] {
    do {
        let (fileExtensionsSet, ignoreSet, allFiles) = (Set(fileExtensions), Set(ignore), try FileManager.default.subpathsOfDirectory(atPath: projectPath))

        var objCFiles: [String] = []

        for file in allFiles {
            if fileExtensionsSet.contains(where: { file.hasSuffix($0) }) &&
               !ignoreSet.contains(where: { file.hasPrefix($0) }) {
                objCFiles.append("\(file)")
            }
        }
        return objCFiles
    } catch {
        return []
    }
}
