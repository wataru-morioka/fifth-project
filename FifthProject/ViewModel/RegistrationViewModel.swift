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
//    let insertUserId = BehaviorRelay<String>(value: "")
    //TODO 初期値
    var insertRegion: BehaviorRelay<String>
    var insertAge: BehaviorRelay<Int>
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    init (input: (region: Observable<String>, age: Observable<Int>)) {
        self.insertRegion = BehaviorRelay<String>(value: realm.objects(User.self).first?.region ?? Singleton.regions[0])
        self.insertAge = BehaviorRelay<Int>(value: realm.objects(User.self).first?.age ?? Singleton.ages[0])
        
//        input.id.flatMap{x -> Observable<String> in
//                            Observable.just(String(x.prefix(Singleton.maxLength)))
//                        }.bind(to: insertUserId).disposed(by: disposeBag)
        input.region.bind(to: insertRegion).disposed(by: disposeBag)
        input.age.bind(to: insertAge).disposed(by: disposeBag)
    }
    
    func registerUser() -> (result: Bool, errMessage: String) {
        print(insertRegion.value)
        print(insertAge.value)
        
        let userId = Auth.auth().currentUser?.uid
        
        //firebase登録
        db.collection("users").document(userId!).setData([
            "userId": userId!,
            "region": insertRegion.value,
            "age": insertAge.value,
        ]) { error in
            if let error = error {
                // エラー処理
                print("サーバエラー")
                print(error)
                return
            }
            // 成功したときの処理
            print("success")
        }
        
        let user = User()
        user.userId = userId!
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
    
    func updateUser() -> (result: Bool, errMessage: String) {
        let userId = Auth.auth().currentUser?.uid
        //firebase登録
        db.collection("users").document(userId!).setData([
            "userId": userId!,
            "region": insertRegion.value,
            "age": insertAge.value,
        ]) { error in
            if let error = error {
                // エラー処理
                print("サーバエラー")
                print(error)
                return
            }
            // 成功したときの処理
            print("success")
        }
        
        return (result: true, errMessage: "success")
    }
}
