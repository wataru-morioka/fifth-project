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
}
