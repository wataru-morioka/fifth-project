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
    var newQuestionListener: ListenerRegistration!
    var ownResultListener: ListenerRegistration!
    var othersResultListener: ListenerRegistration!
    var attachFlag = false
    static let runningProcess = ServerMonitoringService()
    
    private init() {}
    
    func attachListener() {
        print("サーバ監視開始")
        if self.attachFlag {
            return
        }
        fetchNewQuestion()
        fetchOwnQuestionnResult()
        fetchOhersQuestioinResult()
        self.attachFlag = true
    }
    
    func detachListener() {
        print("サーバ監視終了")
        self.newQuestionListener.remove()
        self.ownResultListener.remove()
        self.othersResultListener.remove()
        self.attachFlag = false
    }
    
    private func fetchNewQuestion(){
        self.newQuestionListener = db.collection("targets")
        .whereField("uid", isEqualTo: uid)
        .whereField("askReceiveFlag", isEqualTo: false)
        .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            var serverQuestionIdArray = [String]()
            documents.forEach{
                let documentId = $0.documentID
                let target = $0.data()
                let serverQuestionId = target["serverQuestionId"] as! String
                
                if serverQuestionIdArray.contains(serverQuestionId) { return }
                serverQuestionIdArray.append(serverQuestionId)
                
                let alreadyCount = self.realm.objects(Question.self).filter("serverQuestionId == %@", serverQuestionId).count
                if alreadyCount > 0 { return }
                
                let now = Common.getNowStringFormat()
                self.db.collection("questions").document(serverQuestionId).getDocument{ (document, error) in
                    let question = Question()
                    question.serverQuestionId = serverQuestionId
                    question.owner = Constant.others
                    question.uid = self.uid
                    question.question = document?.data()!["question"] as! String
                    question.answer1 = document?.data()!["answer1"] as! String
                    question.answer2 = document?.data()!["answer2"] as! String
                    question.timeLimit = target["timeLimit"] as? String
                    question.targetNumber = document?.data()!["targetNumber"] as! Int
                    question.createdDateTime = now
                    try! self.realm.write {
                        let _ = question.save()
                    }
                   
                    print("新着質問受信")
                    self.db.collection("targets")
                        .document(documentId)
                        //                        .delete()
                        .updateData([
                            "askReceiveFlag": true
                        ]) { error in
                            if let error = error {
                                print("サーバエラー：新規質受信完了をサーバに周知")
                                print(error)
                                return
                            }
                            print("新規質受信完了をサーバに周知")
                    }
                }
            }
        }
    }
    
    private func fetchOwnQuestionnResult(){
        self.ownResultListener = db.collection("questions")
        .whereField("uid", isEqualTo: uid)
        .whereField("determinationFlag", isEqualTo: true)
        .whereField("finalPushFlag", isEqualTo: true)
        .whereField("resultReceiveFlag", isEqualTo: false)
        .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            documents.forEach{
                let documentId = $0.documentID
                let serverQuestion = $0.data()
                let clientQuestionId = serverQuestion["clientQuestionId"] as! Int64
                let now = Common.getNowStringFormat()
                
                guard let question = self.realm.objects(Question.self).filter("id == %@ and determinationFlag == %@", clientQuestionId, false).first else { return }
                try! self.realm.write {
                    question.answer1number = serverQuestion["answer1number"] as! Int
                    question.answer2number = serverQuestion["answer2number"] as! Int
                    question.determinationFlag = true
                    question.modifiedDateTime = now
                }
                print("自分の質問集計完了")
                
                self.db.collection("questions")
                    .document(documentId)
                    //                        .delete()
                    .updateData([
                        "resultReceiveFlag": true
                    ]) { error in
                        if let error = error {
                            print("サーバエラー：自分の質問集計完了をサーバに周知")
                            print(error)
                            return
                        }
                        print("自分の質問集計完了をサーバに周知")
                }
            }
        }
    }
    
    private func fetchOhersQuestioinResult(){
        self.othersResultListener = db.collection("targets")
        .whereField("uid", isEqualTo: uid)
        .whereField("determinationFlag", isEqualTo: true)
        .whereField("finalPushFlag", isEqualTo: true)
        .whereField("resultReceiveFlag", isEqualTo: false)
        .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            documents.forEach{
                let documentId = $0.documentID
                let target = $0.data()
                let serverQuestionId = target["serverQuestionId"] as! String
                let now = Common.getNowStringFormat()
                
                guard let question = self.realm.objects(Question.self).filter("serverQuestionId == %@ and determinationFlag == %@", serverQuestionId, false).first else { return }
                
                self.db.collection("questions").document(serverQuestionId).getDocument{ (document, error) in
                    try! self.realm.write {
                        question.answer1number = document?.data()!["answer1number"] as! Int
                        question.answer2number = document?.data()!["answer2number"] as! Int
                        question.determinationFlag = true
                        question.confirmationFlag = false
                        question.modifiedDateTime = now
                    }
                    print("他人の質問集計完了")
                    
                    self.db.collection("targets")
                        .document(documentId)
                        //                        .delete()
                        .updateData([
                            "resultReceiveFlag": true
                        ]) { error in
                            if let error = error {
                                print("サーバエラー：他人の質問集計完了をサーバに周知")
                                print(error)
                                return
                            }
                            print("他人の質問集計完了をサーバに周知")
                    }
                }
            }
        }
    }
}
