/*
SERIAL.swift
 
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
import JavaScriptCore

func loadseriallib(process: JavaScriptProcess) {
    let jsinit_readline: @convention(block) (String) -> String = { prompt in
        let semaphore = DispatchSemaphore(value: 0)
        var capture: String = ""
        DispatchQueue.main.async {
            process.terminal.terminalText.text.append(prompt)
        }
        DispatchQueue.main.async {
            process.terminal.setInput { character in
                process.terminal.terminalText.text.append(character)
                capture.append(character)
                if character == "\n" {
                    semaphore.signal()
                }
            }
            process.terminal.setDeletion { _ in
                if !capture.isEmpty {
                    process.terminal.terminalText.text.removeLast()
                    capture.removeLast()
                }
            }
        }
        semaphore.wait()
        DispatchQueue.main.async {
            process.terminal.setInput { _ in }
            process.terminal.setDeletion { _ in }
        }
        capture.removeLast()
        return capture
    }
    
    let getChar: @convention(block) () -> String = {
        let semaphore = DispatchSemaphore(value: 0)
        var capturedCharacter: String = ""
        DispatchQueue.main.async {
            process.terminal.setInput { character in
                if capturedCharacter.isEmpty {
                    capturedCharacter = character
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()
        DispatchQueue.main.async {
            process.terminal.setInput { _ in }
            process.terminal.setDeletion { _ in }
        }

        return capturedCharacter
    }
    
    let serial_dup2: @convention(block) (Int) -> Void = { id in
        DispatchQueue.main.async {
            process.terminal.setInput { out in
                process.fd[id] = out
            }
        }
    }
    let write: @convention(block) (Int,String) -> Void = { id,content in
        process.fd[id] = content
    }
    let read: @convention(block) (Int) -> String = { id in
        return process.fd[id]
    }
    
    let jsinit_clear: @convention(block) () -> Void = {
        DispatchQueue.main.async {
            process.terminal.terminalText.text = ""
        }
    }
    
    let jsinit_osprint: @convention(block) (String) -> Void = { message in
        extern_deeplog(message)
    }
    
    let jsinit_print: @convention(block) (String) -> Void = { message in
        DispatchQueue.main.async {
            process.terminal.terminalText.text.append(message)
        }
    }

    let jsinit_tokenizer: @convention(block) (String,String) -> [String] = { sequence,seperator in
        return sequence.components(separatedBy: seperator)
    }
    
    let serial_setBackground: @convention(block) (UInt8, UInt8, UInt8) -> Void = { r, g, b in
        DispatchQueue.main.sync {
            let color = UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: 1.0
            )
            process.terminal.terminalText.backgroundColor = color
            refreshcolor()
        }
    }
    
    let serial_setTextColor: @convention(block) (UInt8, UInt8, UInt8) -> Void = { r, g, b in
        DispatchQueue.main.sync {
            let color = UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: 1.0
            )
            process.terminal.terminalText.textColor = color
        }
    }
    
    let serial_cursorMove: @convention(block) (Int, Int) -> Void = { x, y in
        DispatchQueue.main.async {
            process.terminal.terminalText.selectedRange = NSMakeRange(x, y)
        }
    }
    
    let serial_setTextSize: @convention(block) (UInt8) -> Void = { size in
        DispatchQueue.main.async {
            process.terminal.terminalText.font = process.terminal.terminalText.font?.withSize(CGFloat(size))
        }
    }
    
    let serial_setTitle: @convention(block) (String) -> Void = { title in
        DispatchQueue.main.async {
            process.terminal.name = title
            refresh()
        }
    }
    
    ld_add_symbol(symbol: jsinit_osprint, name: "osprint", process: process)
    ld_add_symbol(symbol: jsinit_print, name: "print", process: process)
    ld_add_symbol(symbol: jsinit_readline, name: "readline", process: process)
    ld_add_symbol(symbol: getChar, name: "getchar", process: process)
    ld_add_symbol(symbol: jsinit_clear, name: "clear", process: process)
    ld_add_symbol(symbol: jsinit_tokenizer, name: "tokenizer", process: process)
    ld_add_symbol(symbol: serial_setBackground, name: "serial_setBackground", process: process)
    ld_add_symbol(symbol: serial_setTextColor, name: "serial_setTextColor", process: process)
    ld_add_symbol(symbol: serial_setTextSize, name: "serial_setTextSize", process: process)
    ld_add_symbol(symbol: serial_setTitle, name: "serial_setTitle", process: process)
    ld_add_symbol(symbol: serial_cursorMove, name: "serial_cursorMove", process: process)
    ld_add_symbol(symbol: write, name: "write", process: process)
    ld_add_symbol(symbol: read, name: "read", process: process)
    ld_add_symbol(symbol: serial_dup2, name: "serial_dup2", process: process)
}
