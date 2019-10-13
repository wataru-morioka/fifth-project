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

// firebase認証用idトークン取得、更新イベント検知サービス
class TokenMonitoringService {
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    init() {
        // ブロードキャストされたトークンをキャッチするリスナー登録
        NotificationCenter.default.addObserver(self, selector: #selector(setToken), name: NSNotification.Name("getToken"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setToken), name: NSNotification.Name("updateToken"), object: nil)
        
        // トークン取得処理起動
        Common.getToken()
    }
    
    // イベントキャッチ後、取得したトークンをサーバに登録
    @objc func setToken(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo found in notification")
            return
        }
        
        let now = Common.getNowStringFormat()
        let userId = Constant.uid
        
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
