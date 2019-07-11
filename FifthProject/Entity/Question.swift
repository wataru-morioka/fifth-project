//
//  Question.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RealmSwift

class Question: BaseModel, Codable {
    // カラム定義
    @objc dynamic var serverQuestionId: Int64 = 0
    @objc dynamic var owner: String = ""
    @objc dynamic var uid: String = ""
    @objc dynamic var question: String = ""
    @objc dynamic var answer1: String = ""
    @objc dynamic var answer2: String = ""
    @objc dynamic var answer1number: Int = 0
    @objc dynamic var answer2number: Int = 0
    @objc dynamic var decision: Int = 0
    @objc dynamic var targetNumber: Int = 0
    @objc dynamic var timePeriod: Int = 0
    @objc dynamic var timeLimit: String?
    @objc dynamic var confirmationFlag: Bool = false
    @objc dynamic var determinationFlag: Bool = false
    @objc dynamic var createdDateTime: String = ""
    @objc dynamic var modifiedDateTime: String?
//    // プライマリキーの定義
//    override public static func primaryKey() -> String? {
//        return "id"
//    }
}
