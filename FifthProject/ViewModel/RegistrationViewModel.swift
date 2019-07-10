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
        var result = false
        var message = ""
        
        let now = Singleton.getNowStringFormat()
        
        //firebase登録
        db.collection("users").document(userId!).setData([
            "uid": userId!,
            "region": insertRegion.value,
            "age": insertAge.value,
            "token": "",
            "deleteFlag": false,
            "createdDateTime": now,
            "modifiedDateTime": ""
        ]) { error in
            if let error = error {
                print("サーバエラー")
                print(error)
                message = "更新に失敗しました"
                return
            }
            print("success")
            let user = User()
            user.uid = userId!
            user.region = self.insertRegion.value
            user.age = self.insertAge.value
            user.createdDateTime = Singleton.getNowStringFormat()
            
            //Realm登録
            try! self.realm.write {
                self.realm.add(user)
            }
            result = true
        }
        
        return (result: result, errMessage: message)
    }
    
    func updateUser() -> (result: Bool, errMessage: String) {
        let now = Singleton.getNowStringFormat()
        let userId = Auth.auth().currentUser?.uid
        var result = false
        var message = ""
        //firebase登録
        db.collection("users").document(userId!).updateData([
            "region": insertRegion.value,
            "age": insertAge.value,
            "modifiedDateTime": now
        ]) { error in
            if let error = error {
                print("サーバエラー")
                print(error)
                message = "更新に失敗しました"
                return
            }
            print("success")
            let relam = try! Realm()
            let myInfo = relam.objects(User.self).first!
            try! self.realm.write {
                myInfo.region = self.insertRegion.value
                myInfo.age = self.insertAge.value
                myInfo.modifiedDateTime = now
            }
            result = true
        }
        
        return (result: result, errMessage: message)
    }
}
