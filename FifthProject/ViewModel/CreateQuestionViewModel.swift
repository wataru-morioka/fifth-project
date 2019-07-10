//
//  CreateQuestionViewModel.swift
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

class CreateQuestionViewModel {
    let disposeBag = DisposeBag()
    let insertQuestioin = BehaviorRelay<String>(value: "")
    let insertAnswer1 = BehaviorRelay<String>(value: "")
    let insertAnswer2 = BehaviorRelay<String>(value: "")
    let insertTargetNumber = BehaviorRelay<Int>(value: 20)
    let insertTimtPeriod = BehaviorRelay<Int>(value: 5)
    let insertTimeUnit = BehaviorRelay<Int>(value: 60)
    let isValid = BehaviorRelay<Bool>(value: false)
    var timePeriodArray = BehaviorRelay<[Int]>(value: ([Int])(1...60))
    
//    let test = BehaviorRelay<Bool>(value: false)
//    let test2 = BehaviorRelay<Bool>(value: false)
//    let test3 = BehaviorRelay<Bool>(value: false)
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    init (input: (question: Observable<String>, answer1: Observable<String>, answer2: Observable<String>, targetNumber: Observable<Int>, timePeriod: Observable<Int>, timeUnit: Observable<String>)) {
        input.question.map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }.bind(to: insertQuestioin).disposed(by: disposeBag)
        input.answer1.map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }.bind(to: insertAnswer1).disposed(by: disposeBag)
        input.answer2.map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }.bind(to: insertAnswer2).disposed(by: disposeBag)
        
        input.question.map{ q in self.checkInputString(inputString: q)
//                            Observable.just(self.checkInputString(inputString: q))
                        }.flatMap { tmpResult -> Observable<Bool> in
                            input.answer1.map{ a1 in self.checkInputString(inputString: a1) && tmpResult}
                        }.flatMap { tmpResult -> Observable<Bool>  in
                            input.answer2.map{ a1 in self.checkInputString(inputString: a1) && tmpResult}
                        }.bind(to: isValid)
                        .disposed(by: disposeBag)
        
        input.targetNumber.bind(to: insertTargetNumber).disposed(by: disposeBag)
        input.timePeriod.bind(to: insertTimtPeriod).disposed(by: disposeBag)
        
        input.timeUnit.map{ unit in
            Singleton.timeUnitDictionary[unit]!
        }.bind(to: insertTimeUnit)
        .disposed(by: disposeBag)
        
        input.timeUnit.map{ unit in
            Singleton.timePeriodDictionary[unit]!
        }.bind(to: timePeriodArray)
        .disposed(by: disposeBag)
        
//        input.question.map {self.checkInputString(inputString: $0)}.bind(to: test).disposed(by: disposeBag)
//        input.answer1.map {self.checkInputString(inputString: $0)}.bind(to: test2).disposed(by: disposeBag)
//        input.answer2.map {self.checkInputString(inputString: $0)}.bind(to: test3).disposed(by: disposeBag)
    }
    
    func checkInputString(inputString: String) -> Bool {
        let targetString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
        if targetString.count == 0 {
            return false
        }
        return true
    }
    
    func submitQuestion() -> (result: Bool, errMessage: String) {
        print(insertTargetNumber.value)
        print(insertTimtPeriod.value)
        print(insertTimeUnit.value)
        let userId = Auth.auth().currentUser?.uid
        var result = false
        var message = ""
        
        let now = Singleton.getNowStringFormat()
        
        //TODO オフラインの場合考慮
        let question = Question()
        question.createdDateTime = Singleton.getNowStringFormat()

        //Realm登録
        var questionId: Int?
        try! self.realm.write {
            questionId = question.save()
        }
        
        //firebase登録
        db.collection("questions").addDocument(data: [
            "seq": FieldValue.increment(1.0),
            "uid": userId!,
            "questionId": questionId!,
            "question": insertQuestioin.value,
            "answer1": insertAnswer1.value,
            "answer2": insertAnswer2.value,
            "answer1number": 0,
            "answer2number": 0,
            "targetNumber": 10,
            "timePeriod": 5,
            "timeLimit": "",
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
//            let question = Question()
//            question.createdDateTime = Singleton.getNowStringFormat()
//
//            //Realm登録
//            try! self.realm.write {
//                self.realm.add(question)
//            }
            result = true
        }
        
        return (result: result, errMessage: message)
    }
}
