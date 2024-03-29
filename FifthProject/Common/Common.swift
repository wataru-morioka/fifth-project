//
//  Common.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/07.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import RealmSwift

class Common {
    // 画面遷移
    func moveToView(fromView: UIWindow?, toView: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: toView)
        fromView?.rootViewController = initialViewController
        fromView?.makeKeyAndVisible()
    }
    
    static func getNowDate(target: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter.date(from: target)!
    }
    
    static func getNowStringFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter.string(from: Date())
    }
    
    // ローカルタイム取得
    static func changeToLocalDateTime(target: String) -> String{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        let localDateTime = formatter.date(from: target)
        return formatter.string(from: localDateTime!)
    }
    
    // firebase認証用idトークン取得
    static func getToken() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                print(String(format: "トークン取得：%@", result.token))
                NotificationCenter.default.post(name: Notification.Name("getToken"), object: nil, userInfo: ["token": result.token])
            }
        }
    }
    
    // 更新した情報をユーザがタップして確認していない件数の総数を取得
    static func getUnconfirmCount() -> Int {
        return getUncorimCount(owner: Constant.own) + getUncorimCount(owner: Constant.others)
    }
    
    // 上記の件数を、自分の質問か他人の質問かで振り分ける
    static func getUncorimCount(owner: String) -> Int {
        let realm = try! Realm()
        switch owner{
        case Constant.own:
            return realm.objects(Question.self).filter("owner = %@ and determinationFlag == %@ and confirmationFlag == %@", Constant.own, true, false).count
        case Constant.others:
            return realm.objects(Question.self).filter("owner = %@ and confirmationFlag == %@", Constant.others, false).count
        default:
            return 0
        }
    }
}
