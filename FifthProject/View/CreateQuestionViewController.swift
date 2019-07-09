//
//  CreateQuestionViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import Firebase

class CreateQuestionTableViewController: UITableViewController {

//    @IBOutlet weak var questionSection: UITableViewSection!
    
    @IBOutlet weak var inputQuestion: UITextField!
    @IBOutlet weak var inputAnswer1: UITextField!
    @IBOutlet weak var inputAnswer2: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
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
        
        let swipeL = UISwipeGestureRecognizer()
        swipeL.direction = .left
        swipeL.numberOfTouchesRequired = 1
        swipeL.addTarget(self, action: #selector(self.swipeLeft(sender:)))
        self.view.addGestureRecognizer(swipeL)
        
        let swipeR = UISwipeGestureRecognizer()
        swipeR.direction = .right
        swipeR.numberOfTouchesRequired = 1
        swipeR.addTarget(self, action: #selector(self.swipeRight(sender:)))
        self.view.addGestureRecognizer(swipeR)
    }
    
    @objc func swipeLeft(sender:UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex = 3
    }
    
    @objc func swipeRight(sender:UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
}
