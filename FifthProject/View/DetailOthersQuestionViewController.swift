//
//  DetailOthersQuestionViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit

class DetailOthersQuestionViewController: UITableViewController {
    var questionId: Int!
    @IBOutlet weak var questionView: UITextView!
    @IBOutlet weak var answer1perView: UILabel!
    @IBOutlet weak var answer1numView: UILabel!
    @IBOutlet weak var answer1View: UITextView!
    @IBOutlet weak var answer2perView: UILabel!
    @IBOutlet weak var answer2numView: UILabel!
    @IBOutlet weak var answer2View: UITextView!
    @IBOutlet weak var answerSegment: UISegmentedControl!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
