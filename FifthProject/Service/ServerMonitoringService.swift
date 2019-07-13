//
//  ServerMonitoringService.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/13.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import RealmSwift
import RxRealm

class ServerMonitoringService {
    let db = Firestore.firestore()
    let realm = try! Realm()
    let uid = Auth.auth().currentUser!.uid
    
    init() {
        fetchNewQuestion()
//        fetchOwnQuestionnResult()
//        fetchOhersQuestioinResult()
    }
    
    private func fetchNewQuestion(){
        db.collection("targets")
            .whereField("uid", isEqualTo: uid)
            .whereField("askReceiveFlag", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                documents.forEach{
                    print(String(format: "検知成功：%@", $0.data()["serverQuestioinId"] as! CVarArg))
                    //realm登録
                    
                    
                    
                    //firestoreのfフラグ更新
                    
                    
                    
                }
        }
    }
    
    private func fetchOwnQuestionnResult(){
        db.collection("questions")
            .whereField("uid", isEqualTo: uid)
            .whereField("determinationFlag", isEqualTo: true)
            .whereField("resultReceiveFlag", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                documents.forEach{
                    print(String(format: "検知成功：%@", $0.data()["clientQuestionId"] as! CVarArg))
                    //realm登録
                    
                    
                    
                    //firestoreのfフラグ更新
                    
                    
                    
                }
        }
    }
    
    private func fetchOhersQuestioinResult(){
        db.collection("targets")
            .whereField("uid", isEqualTo: uid)
            .whereField("determinationFlag", isEqualTo: true)
            .whereField("askReceiveFlag", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                documents.forEach{
                    print(String(format: "検知成功：%@", $0.data()["serverQuestioinId"] as! CVarArg))
                    //realm登録
                    
                    
                    
                    //firestoreのfフラグ更新
                    
                    
                    
                }
        }
    }
}
