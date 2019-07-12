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
    
    init(input: Observable<Int>){
        input.bind(to: decision).disposed(by: self.disposeBag)
        
    }
    
    func answer() {
        let userId = Singleton.uid
        
        
        answerResult.accept(true)
        
    }
}
