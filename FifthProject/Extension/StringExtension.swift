//
//  StringExtension.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/11.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation

extension String {
    func rightTrimmingCharacters(in set: CharacterSet) -> String {
        for c in self.reversed().enumerated() {
            let isMatch = c.element.unicodeScalars.contains { set.contains($0) }
            if !isMatch {
//                return String(self[startIndex..<index(endIndex, offsetBy: -c.offset)])
                // swift4
                return String(prefix(upTo: index(endIndex, offsetBy: -c.offset)))
            }
        }
        return ""
    }
    
    func leftTrimmingCharacters(in set: CharacterSet) -> String {
        for c in self.enumerated() {
            let isMatch = c.element.unicodeScalars.contains { set.contains($0) }
            if !isMatch {
//                return String(self[index(startIndex, offsetBy: c.offset)..<endIndex])
                // swift4
                return String(suffix(from: index(startIndex, offsetBy: c.offset)))
            }
        }
        return ""
    }

    func trimingLeftRight() -> String {
        return self.leftTrimmingCharacters(in: .whitespacesAndNewlines).rightTrimmingCharacters(in: .whitespacesAndNewlines)
    }
}
