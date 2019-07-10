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
    let submitResult = PublishRelay<Bool>()
    var timePeriodArray = BehaviorRelay<[Int]>(value: ([Int])(1...60))
    
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
        
//        db.collection("questions").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
//            .addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("Error fetching documents: \(error!)")
//                    return
//                }
//                let time = documents.map { $0["createdDateTime"]! }
//                print(String(format: "検知成功：%@", time))
//        }
    }
    
    func checkInputString(inputString: String) -> Bool {
        let targetString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
        if targetString.count == 0 {
            return false
        }
        return true
    }
    
    func submitQuestion() {
        print(insertTargetNumber.value)
        print(insertTimtPeriod.value)
        print(insertTimeUnit.value)
        let userId = Auth.auth().currentUser?.uid
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
            "uid": userId!,
            "questionId": questionId!,
            "question": insertQuestioin.value,
            "answer1": insertAnswer1.value,
            "answer2": insertAnswer2.value,
            "answer1number": 0,
            "answer2number": 0,
            "targetNumber": insertTargetNumber.value,
            "timePeriod": insertTimtPeriod.value * insertTimeUnit.value,
            "timeLimit": "",
            "askFlag": false,
            "determinationFlag": false,
            "finalPushFlag": false,
            "resultReceiveFlag": false,
            "createdDateTime": now,
            "modifiedDateTime": ""
        ]) { error in
            if let error = error {
                print("サーバエラー")
                print(error)
                self.submitResult.accept(false)
                return
            }
            print("success")
            self.insertQuestioin.accept("")
            self.insertAnswer1.accept("")
            self.insertAnswer2.accept("")
//            let question = Question()
//            question.createdDateTime = Singleton.getNowStringFormat()
//
//            //Realm登録
//            try! self.realm.write {
//                self.realm.add(question)
//            }
            self.submitResult.accept(true)
        }
    }
}
