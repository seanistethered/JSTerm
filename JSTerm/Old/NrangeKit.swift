/*
NrangeKit.swift
 
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

import Foundation
import UIKit

func findRanges(of word: String, in text: String) -> [NSRange] {
    let nsText = NSString(string: text)
    var ranges: [NSRange] = []

    var searchRange = NSRange(location: 0, length: nsText.length)

    while true {
        let range = nsText.range(of: word, options: [], range: searchRange)

        if range.location == NSNotFound {
            break
        }

        ranges.append(range)

        let newLocation = range.location + range.length
        searchRange = NSRange(location: newLocation, length: nsText.length - newLocation)
    }

    return ranges
}

func setSelectedTextRange(for textView: UITextView, with askedRange: NSRange) {
    guard let text = textView.text,
          askedRange.location != NSNotFound,
          askedRange.location + askedRange.length <= text.count else {
        return
    }

    let caretRange = NSRange(location: askedRange.location + askedRange.length, length: 0)

    let startPosition = textView.position(from: textView.beginningOfDocument, offset: caretRange.location)
    let endPosition = textView.position(from: startPosition!, offset: 0)

    let textRange = textView.textRange(from: startPosition!, to: endPosition!)
    textView.selectedTextRange = textRange
}

func visualRangeRect(in textView: UITextView, for textRange: NSRange) -> CGRect? {
    guard textRange.location != NSNotFound,
          textRange.location + textRange.length <= textView.textStorage.length else {
          return nil
    }

    let layoutManager = textView.layoutManager
    let textContainer = textView.textContainer
    let glyphRange = layoutManager.glyphRange(forCharacterRange: textRange, actualCharacterRange: nil)

    var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

    rect.origin.x += textView.textContainerInset.left
    rect.origin.y += textView.textContainerInset.top

    return rect
}
