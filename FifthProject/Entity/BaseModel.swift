//
//  BaseModel.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/10.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RealmSwift

class BaseModel: Object {
    // ID
    @objc dynamic var id = 0
    
    // データを保存。
    func save() -> Int {
        let realm = try! Realm()
        let newId = self.createNewId()
        if realm.isInWriteTransaction {
            if self.id == 0 { self.id = newId }
            realm.add(self)
        } else {
            try! realm.write {
                if self.id == 0 { self.id = newId }
                realm.add(self)
            }
        }
        return newId
    }
    
    // 新しいIDを採番します。
    private func createNewId() -> Int {
        let realm = try! Realm()
        return (realm.objects(type(of: self).self).sorted(byKeyPath: "id", ascending: false).first?.id ?? 0) + 1
    }
    
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
