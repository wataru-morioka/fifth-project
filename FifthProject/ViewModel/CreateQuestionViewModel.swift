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
    //TODO 初期値
    let insertTargetNumber = BehaviorRelay<Int>(value: 3)
    let insertTimtPeriod = BehaviorRelay<Int>(value: 5)
    let insertTimeUnit = BehaviorRelay<Int>(value: 1)
    let timeUnit = BehaviorRelay<String>(value: "分")
    let isValid = BehaviorRelay<Bool>(value: false)
    let submitResult = PublishRelay<Bool>()
    var timePeriodArray = BehaviorRelay<[Int]>(value: ([Int])(1...60))
    
    
    let test = BehaviorRelay<Bool>(value: false)
    let test2 = BehaviorRelay<Bool>(value: false)
    let test3 = BehaviorRelay<Bool>(value: false)
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    init (input: (question: Observable<String>, answer1: Observable<String>, answer2: Observable<String>, targetNumber: Observable<Int>, timePeriod: Observable<Int>, timeUnit: Observable<String>)) {
        input.question.bind(to: insertQuestioin).disposed(by: disposeBag)
        input.answer1.bind(to: insertAnswer1).disposed(by: disposeBag)
        input.answer2.bind(to: insertAnswer2).disposed(by: disposeBag)
        bindIsValid(inputArea: input.question)
        bindIsValid(inputArea: input.answer1)
        bindIsValid(inputArea: input.answer2)
        
        input.targetNumber.bind(to: insertTargetNumber).disposed(by: disposeBag)
        input.timePeriod.bind(to: insertTimtPeriod).disposed(by: disposeBag)
        
        input.timeUnit.bind(to: timeUnit).disposed(by: disposeBag)
        input.timeUnit.map{ unit in
            Singleton.timeUnitDictionary[unit]!
        }.bind(to: insertTimeUnit)
        .disposed(by: disposeBag)
        
        input.timeUnit.map{ unit in
            Singleton.timePeriodDictionary[unit]!
        }.bind(to: timePeriodArray)
        .disposed(by: disposeBag)
    }
    
    func bindIsValid(inputArea: Observable<String>) {
        inputArea.flatMap{ i -> Observable<Bool> in
                self.insertQuestioin.map{ q in self.checkInputString(inputString: q) }
            }.flatMap { tmpResult -> Observable<Bool> in
                self.insertAnswer1.map{ a1 in self.checkInputString(inputString: a1) && tmpResult}
            }.flatMap { tmpResult -> Observable<Bool>  in
                self.insertAnswer2.map{ a2 in self.checkInputString(inputString: a2) && tmpResult}
            }.bind(to: isValid)
            .disposed(by: disposeBag)
    }
    
    func checkInputString(inputString: String) -> Bool {
        let targetString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
        if targetString.count == 0 {
            return false
        }
        return true
    }
    
    func submitQuestion() {
        let userId = Singleton.uid
        let now = Singleton.getNowStringFormat()
        
        //TODO オフラインの場合考慮
        let question = Question()
        question.uid = userId
        question.owner = Singleton.own
        question.question = insertQuestioin.value.trimingLeftRight()
        question.answer1 = insertAnswer1.value.trimingLeftRight()
        question.answer2 = insertAnswer2.value.trimingLeftRight()
        question.targetNumber = insertTargetNumber.value
        question.timePeriod = insertTimtPeriod.value
        question.timeUnit = timeUnit.value
        question.createdDateTime = now

        //Realm登録
        var questionId: Int?
        try! self.realm.write {
            questionId = question.save()
        }
        
        //firebase登録
        db.collection("questions").addDocument(data: [
            "uid": userId,
            "clientQuestionId": questionId!,
            "question": insertQuestioin.value.trimingLeftRight(),
            "answer1": insertAnswer1.value.trimingLeftRight(),
            "answer2": insertAnswer2.value.trimingLeftRight(),
            "answer1number": 0,
            "answer2number": 0,
            "targetNumber": insertTargetNumber.value,
            "timePeriod": insertTimtPeriod.value * insertTimeUnit.value,
            "timeUnit": timeUnit.value,
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
            self.submitResult.accept(true)
        }
    }
}
