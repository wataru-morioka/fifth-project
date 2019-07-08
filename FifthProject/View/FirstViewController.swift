//
//  FirstViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/04.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!.uid)
            print(Auth.auth().currentUser!.email ?? "")
            print("ログイン中")
            //self.performSegue(withIdentifier: "toRegistrationView", sender: nil)
        } else {
            print("ログアウト")
        }
        
    }


}

