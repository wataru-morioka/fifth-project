//
//  TokenMonitoringService.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/14.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import RealmSwift

class TokenMonitoringService {
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(setToken), name: NSNotification.Name("getToken"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setToken), name: NSNotification.Name("updateToken"), object: nil)
        Singleton.getToken()
    }
    
    @objc func setToken(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo found in notification")
            return
        }
        
        let now = Singleton.getNowStringFormat()
        let userId = Singleton.uid
        
        self.db.collection("users").document(userId).updateData([
            "token": userInfo["token"] as? String ?? "",
            "modifiedDateTime": now
        ]) { error in
            if let error = error {
                print("サーバエラー：トークンサーバに送信")
                print(error)
                return
            }
            print("トークン更新完了")
        }
    }
}
