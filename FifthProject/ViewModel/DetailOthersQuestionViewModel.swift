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
        input.bind(to: decision).disposed(by: self.disposeBag)
        self.serverQuestionId = serverQuestionId
    }
    
    func answer() {
        let userId = Singleton.uid
        let now = Singleton.getNowStringFormat()
        
        //TODO オフラインの場合考慮
        let question = self.realm.objects(Question.self).filter("serverQuestionId == %@", self.serverQuestionId).first!
        try! realm.write {
            question.decision = decision.value
            question.modifiedDateTime = now
        }
        print("他人の質問に回答登録完了")
        
        //firebase登録
        db.collection("answers").addDocument(data: [
            "uid": userId,
            "serverQuestionId": self.serverQuestionId,
            "decisioin": self.decision.value,
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
            self.answerResult.accept(true)
        }
    }
}
