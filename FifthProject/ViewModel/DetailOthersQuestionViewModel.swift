//
//  DetailOthersQuestionViewModel.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import RealmSwift

class DetailOthersQuestionViewModel {
    let decision = BehaviorRelay<Int>(value: 1)
    let answerResult = PublishRelay<Bool>()
    let disposeBag = DisposeBag()
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    var serverQuestionId: String
    
    init(input: Observable<Int>, serverQuestionId: String){
        // 画面変更値をBehaviorRelayにバインド
        input.bind(to: decision).disposed(by: self.disposeBag)
        self.serverQuestionId = serverQuestionId
    }
    
    func answer() {
        if !NetworkMonitoringService.isOnline {
            self.answerResult.accept(false)
            return
        }
        
        let userId = Constant.uid
        let now = Common.getNowStringFormat()
        
        // firestore登録
        db.collection("answers").addDocument(data: [
            "uid": userId,
            "serverQuestionId": self.serverQuestionId,
            "decision": self.decision.value,
            "determinationFlag": false,
            "createdDateTime": now
        ]) { error in
            if let error = error {
                print("サーバエラー：回答サーバに送信完了")
                print(error)
                self.answerResult.accept(false)
                return
            }
            print("回答サーバに送信完了")
            // Realm登録
            let question = self.realm.objects(Question.self).filter("serverQuestionId == %@", self.serverQuestionId).first!
            try! self.realm.write {
                question.decision = self.decision.value
                question.modifiedDateTime = now
            }
            print("他人の質問に回答登録完了")
            // view側にイベント送信
            self.answerResult.accept(true)
        }
    }
}
