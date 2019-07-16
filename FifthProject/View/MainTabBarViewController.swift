//
//  MainTabBarViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/16.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //ボタンの個数ぶんループする。
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
