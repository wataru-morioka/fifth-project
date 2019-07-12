//
//  DetailOwnQuestionViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import RealmSwift

class DetailOwnQuestionViewController: UITableViewController {
    @IBOutlet weak var questionView: UITextView!
    @IBOutlet weak var answer1perView: UILabel!
    @IBOutlet weak var answer1numView: UILabel!
    @IBOutlet weak var answer1View: UITextView!
    @IBOutlet weak var answer2perView: UILabel!
    @IBOutlet weak var answer2numView: UILabel!
    @IBOutlet weak var answer2View: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var indeicator: UIActivityIndicatorView!
    
    var questionId: Int!
    let realm = try! Realm()
    var questionDetail: Question!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionDetail = self.realm.objects(Question.self).filter("id == %@", self.questionId!).first
        
        questionView.text = questionDetail.question
        answer1View.text = questionDetail.answer1
        answer2View.text = questionDetail.answer2
        
        
    }
    
    //Headerが表示される時の処理
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        //Headerのラベルの文字色を設定
        header.textLabel?.textColor = UIColor.orange
        header.textLabel?.font = UIFont.systemFont(ofSize: 15)
        //Headerの背景色を設定
        header.contentView.backgroundColor = UIColor.black
        header.isUserInteractionEnabled = true
    }
}
