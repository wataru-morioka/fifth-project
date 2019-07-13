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
    let registerResult = PublishRelay<Bool>()
    let updateResult = PublishRelay<Bool>()
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    init (input: (region: Observable<String>, age: Observable<Int>)) {
        self.insertRegion = BehaviorRelay<String>(value: realm.objects(User.self).first?.region ?? Singleton.regions[0])
        self.insertAge = BehaviorRelay<Int>(value: realm.objects(User.self).first?.age ?? Singleton.ages[0])
        
        input.region.bind(to: insertRegion).disposed(by: disposeBag)
        input.age.bind(to: insertAge).disposed(by: disposeBag)
    }
    
    func registerUser() {
        print(insertRegion.value)
        print(insertAge.value)
        
        let userId = Singleton.uid
        
        let now = Singleton.getNowStringFormat()
        
        //firebase登録
        db.collection("users").document(userId).setData([
            "uid": userId,
            "region": insertRegion.value,
            "age": insertAge.value,
            "token": "",
            "deleteFlag": false,
            "createdDateTime": now,
            "modifiedDateTime": ""
        ]) { error in
            if let error = error {
                print("サーバエラー：ユーザ情報の登録サーバに送信")
                print(error)
                self.registerResult.accept(false)
                return
            }
            print("ユーザ情報の登録サーバに送信完了")
            let user = User()
            user.uid = userId
            user.region = self.insertRegion.value
            user.age = self.insertAge.value
            user.createdDateTime = Singleton.getNowStringFormat()
            
            //Realm登録
            try! self.realm.write {
                self.realm.add(user)
            }
            self.registerResult.accept(true)
        }
    }
    
    func updateUser() {
        let now = Singleton.getNowStringFormat()
        let userId = Singleton.uid
        //firebase登録
        db.collection("users").document(userId).updateData([
            "region": insertRegion.value,
            "age": insertAge.value,
            "modifiedDateTime": now
        ]) { error in
            if let error = error {
                print("サーバエラー：ユーザ情報更新サーバに送信")
                print(error)
                self.updateResult.accept(false)
                return
            }
            print("ユーザ情報更新サーバに送信完了")
            let myInfo = self.realm.objects(User.self).first!
            try! self.realm.write {
                myInfo.region = self.insertRegion.value
                myInfo.age = self.insertAge.value
                myInfo.modifiedDateTime = now
            }
            print("ユーザ情報更新完了")
            self.updateResult.accept(true)
        }
        
//        //firebase登録
//        db.collection("users").document("K").setData([
//            "uid": "K",
//            "region": insertRegion.value,
//            "age": insertAge.value,
//            "token": "",
//            "deleteFlag": false,
//            "createdDateTime": now,
//            "modifiedDateTime": ""
//        ]) { error in
//            if let _ = error {
//                return
//            }
//            print("success")
//        }
    }
}
