//
//  StringExtension.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/11.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation

extension String {
    // 文字列右端の空白削除
    func rightTrimmingCharacters(in set: CharacterSet) -> String {
        for c in self.reversed().enumerated() {
            let isMatch = c.element.unicodeScalars.contains { set.contains($0) }
            if !isMatch {
                return String(prefix(upTo: index(endIndex, offsetBy: -c.offset)))
            }
        }
        return ""
    }
    
    // 文字列左端の空白削除
    func leftTrimmingCharacters(in set: CharacterSet) -> String {
        for c in self.enumerated() {
            let isMatch = c.element.unicodeScalars.contains { set.contains($0) }
            if !isMatch {
                return String(suffix(from: index(startIndex, offsetBy: c.offset)))
            }
        }
        return ""
    }

    // 文字列両端の空白削除
    func trimingLeftRight() -> String {
        return self.leftTrimmingCharacters(in: .whitespacesAndNewlines).rightTrimmingCharacters(in: .whitespacesAndNewlines)
    }
}
