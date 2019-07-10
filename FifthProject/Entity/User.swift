//
//  User.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/07.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object, Codable {
    // カラム定義
    @objc dynamic var uid: String = ""
    @objc dynamic var region: String = ""
    @objc dynamic var age: Int = 0
    @objc dynamic var createdDateTime: String = ""
    @objc dynamic var modifiedDateTime: String?
    // プライマリキーの定義
    override public static func primaryKey() -> String? {
        return "uid"
    }
}
