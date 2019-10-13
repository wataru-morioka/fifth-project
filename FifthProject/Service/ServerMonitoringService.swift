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

// firebase firestoreデータベースのリアルタイム更新監視サービス
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
        // リスナー生成
        fetchNewQuestion()
        fetchOwnQuestionnResult()
        fetchOhersQuestioinResult()
        self.attachFlag = true
    }
    
    func detachListener() {
        print("サーバ監視終了")
        // リスナー削除
        self.newQuestionListener.remove()
        self.ownResultListener.remove()
        self.othersResultListener.remove()
        self.attachFlag = false
    }
    
    // 新規で自分が問い合わせ対象になっった場合、新規質問を取得
    private func fetchNewQuestion(){
        // targetsコレクションの更新監視し、自分が対象になった場合を検知
        self.newQuestionListener = db.collection("targets")
        .whereField("uid", isEqualTo: uid)
        .whereField("askReceiveFlag", isEqualTo: false)
        .addSnapshotListener { querySnapshot, error in
            // 対象targetドキュメントリスト取得
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            var serverQuestionIdArray = [String]()
            // 対象targetドキュメントそれぞれに対し処理実行
            documents.forEach{
                let documentId = $0.documentID
                let target = $0.data()
                let serverQuestionId = target["serverQuestionId"] as! String
                
                if serverQuestionIdArray.contains(serverQuestionId) { return }
                serverQuestionIdArray.append(serverQuestionId)
                
                // すでにネイティブに存在していた場合、処理を抜ける
                let alreadyCount = self.realm.objects(Question.self).filter("serverQuestionId == %@", serverQuestionId).count
                if alreadyCount > 0 { return }
                
                // 対象questionドキュメントを取得
                let now = Common.getNowStringFormat()
                self.db.collection("questions").document(serverQuestionId).getDocument{ (document, error) in
                    // 質問情報をネイティブに保存
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
                    // サーバに保存完了情報更新
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
    
    // 自分の送信した質問の変更を監視
    private func fetchOwnQuestionnResult(){
        // 回答結果の集計が完了したものを検知
        self.ownResultListener = db.collection("questions")
        .whereField("uid", isEqualTo: uid)
        .whereField("determinationFlag", isEqualTo: true)
        .whereField("finalPushFlag", isEqualTo: true)
        .whereField("resultReceiveFlag", isEqualTo: false)
        .addSnapshotListener { querySnapshot, error in
            // 対象questionドキュメントリスト取得
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            // 対象questionドキュメントそれぞれに対し処理実行
            documents.forEach{
                let documentId = $0.documentID
                let serverQuestion = $0.data()
                let clientQuestionId = serverQuestion["clientQuestionId"] as! Int64
                let now = Common.getNowStringFormat()
                
                // 対象質問がネイティブに存在していない場合、処理を抜ける
                guard let question = self.realm.objects(Question.self).filter("id == %@ and determinationFlag == %@", clientQuestionId, false).first else { return }
                
                // 回答結果をネイティブに保存
                try! self.realm.write {
                    question.answer1number = serverQuestion["answer1number"] as! Int
                    question.answer2number = serverQuestion["answer2number"] as! Int
                    question.determinationFlag = true
                    question.modifiedDateTime = now
                }
                print("自分の質問集計完了")
                // サーバに保存完了情報更新
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
    
    // 自分が回答した質問（targetsコレクション）を監視
    private func fetchOhersQuestioinResult(){
        // 回答結果の集計が完了したものを検知
        self.othersResultListener = db.collection("targets")
        .whereField("uid", isEqualTo: uid)
        .whereField("determinationFlag", isEqualTo: true)
        .whereField("finalPushFlag", isEqualTo: true)
        .whereField("resultReceiveFlag", isEqualTo: false)
        .addSnapshotListener { querySnapshot, error in
            // 対象targetドキュメントリスト取得
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            // 対象targetドキュメントそれぞれに対し処理実行
            documents.forEach{
                let documentId = $0.documentID
                let target = $0.data()
                let serverQuestionId = target["serverQuestionId"] as! String
                let now = Common.getNowStringFormat()
                
                // 対象質問がネイティブに存在していない場合、処理を抜ける
                guard let question = self.realm.objects(Question.self).filter("serverQuestionId == %@ and determinationFlag == %@", serverQuestionId, false).first else { return }
                
                // 質問IDによりquestionsコレクションから回答結果を取得し、ネイティブに保存
                self.db.collection("questions").document(serverQuestionId).getDocument{ (document, error) in
                    try! self.realm.write {
                        question.answer1number = document?.data()!["answer1number"] as! Int
                        question.answer2number = document?.data()!["answer2number"] as! Int
                        question.determinationFlag = true
                        question.confirmationFlag = false
                        question.modifiedDateTime = now
                    }
                    print("他人の質問集計完了")
                    // サーバに保存完了情報更新
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
