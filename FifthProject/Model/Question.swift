//
//  Question.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RealmSwift

class Question: Object, Codable {
    // カラム定義
    @objc dynamic var id: Int = 0
    @objc dynamic var userId: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var status: Int = 0
    @objc dynamic var region: String = ""
    @objc dynamic var age: Int = 0
    @objc dynamic var createdDateTime: String = ""
    @objc dynamic var modifiedDateTime: String?
    // プライマリキーの定義
    override public static func primaryKey() -> String? {
        return "id"
    }
}
