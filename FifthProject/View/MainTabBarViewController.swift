//
//  MainTabBarViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/16.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxRealm

class MainTabBarViewController: UITabBarController {
    let realm = try! Realm()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBadgeValue()
        
        // ネイティブの質問の更新情報を監視
        Observable.collection(from: realm.objects(Question.self)).subscribe(onNext: { _ in
            self.setBadgeValue()
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = Common.getUnconfirmCount()
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func setBadgeValue() {
        for item in tabBar.items! {
            switch item.tag {
            case 1:
                let count = Common.getUncorimCount(owner: Constant.own)
                item.badgeValue = count == 0 ? nil : String(count)
            case 2:
                let count = Common.getUncorimCount(owner: Constant.others)
                item.badgeValue = count == 0 ? nil : String(count)
            default:
                break
            }
        }
    }
}
