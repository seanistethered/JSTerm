//
//  Host.swift
//  JSTerm
//
//  Created by fridakitten on 26.12.24.
//

import Foundation
import Swifter

func findFoldersRecursively(at path: String) -> [String] {
    var folderPaths: [String] = []

    // Helper function to recursively explore directories
    func exploreDirectory(at currentPath: String, relativeTo basePath: String) {
        let fileManager = FileManager.default

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: currentPath)
            for item in contents {
                let fullPath = (currentPath as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false

                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory), isDirectory.boolValue {
                    let relativePath = (fullPath as NSString).substring(from: basePath.count)
                    folderPaths.append(relativePath)
                    exploreDirectory(at: fullPath, relativeTo: basePath)
                }
            }
        } catch {
            print("Error while exploring directory at \(currentPath): \(error)")
        }
    }

    // Ensure the path does not end with a trailing slash
    let sanitizedPath = (path as NSString).expandingTildeInPath

    exploreDirectory(at: sanitizedPath, relativeTo: sanitizedPath)

    return folderPaths
}

class HTTP_SERVER_SYSTEM {
    var server: [String:HttpServer]
    
    init() {
        self.server = [:]
    }
    
    func registerServer(name: String) {
        server[name] = HttpServer()
    }
    
    func unregisterServer(name: String) {
        server[name]?.stop()
        server.removeValue(forKey: name)
    }
    
    func setServerAction(name: String, path: String, action: ((HttpRequest) -> HttpResponse)?) {
        guard let selver = server[name] else { return }
        
        selver[path] = action
    }

    
    func startServer(name: String, port: in_port_t) {
        guard let selver = server[name] else { return }
        do {
            try selver.start(port, forceIPv4: true)
        } catch {}
    }
    
    func stopServer(name: String) {
        guard let selver = server[name] else { return }
        selver.stop()
    }
}
