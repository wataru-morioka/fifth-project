//
//  RegistrationViewModel.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/07.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import RealmSwift

class RegistrationViewModel {
    let disposeBag = DisposeBag()
    let insertUserId = BehaviorRelay<String>(value: "")
    //TODO 初期値
    let insertRegion = BehaviorRelay<String>(value: "北海道")
    let insertAge = BehaviorRelay<Int>(value: 5)
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    init (input: (id: Observable<String>, region: Observable<String>, age: Observable<Int>)) {
        input.id.flatMap{x -> Observable<String> in
                            Observable.just(String(x.prefix(Singleton.maxLength)))
                        }.bind(to: insertUserId).disposed(by: disposeBag)
        input.region.bind(to: insertRegion).disposed(by: disposeBag)
        input.age.bind(to: insertAge).disposed(by: disposeBag)
    }
    
    func registerUser() -> (result: Bool, errMessage: String) {
        print(insertUserId.value)
        print(insertRegion.value)
        print(insertAge.value)
        
        let userId = insertUserId.value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if userId.isEmpty {
            return (result: false, errMessage: "IDを入力してください")
        }
        
        //firebase登録
        db.collection("users").document(insertUserId.value).setData([
            "userId": userId,
            "region": insertRegion.value,
            "age": insertAge.value,
        ]) { error in
            if let _ = error {
                // エラー処理
                print("error")
                return
            }
            // 成功したときの処理
            print("success")
        }
        
        let user = User()
        user.userId = userId
        user.password = "test"
        user.status = 0
        user.region = insertRegion.value
        user.age = insertAge.value
        user.createdDateTime = Singleton.getNowStringFormat()
        
        //Realm登録
        try! realm.write {
            realm.add(user)
        }
        
        return (result: true, errMessage: "success")
    }
    
}
