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
    func moveToView(fromView: UIWindow?, toView: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: toView)
        fromView?.rootViewController = initialViewController
        fromView?.makeKeyAndVisible()
    }
    
    func getToken() {
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
}
