//
//  DetailOthersQuestionViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxRealm
import RxCocoa

class DetailOthersQuestionViewController: UITableViewController {
    @IBOutlet weak var questionView: UITextView!
    @IBOutlet weak var answer1perView: UILabel!
    @IBOutlet weak var answer1numView: UILabel!
    @IBOutlet weak var answer1View: UITextView!
    @IBOutlet weak var answer2perView: UILabel!
    @IBOutlet weak var answer2numView: UILabel!
    @IBOutlet weak var answer2View: UITextView!
    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var targetNumberLabel: UILabel!
    @IBOutlet weak var yourChoiceLabel: UILabel!
    @IBOutlet weak var answerSegment: UISegmentedControl!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var questionId: Int!
    let realm = try! Realm()
    var observableQuestion: Results<Question>!
    let disposeBag = DisposeBag()
    let decision = BehaviorRelay<Int>(value: 1)
    var timeLimit: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 質問詳細情報取得
        observableQuestion = self.realm.objects(Question.self).filter("id == %@", self.questionId!)
        // 画面にセット（ネイティブデータ更新を監視し、リアルタイムに画面に反映）
        Observable.collection(from: observableQuestion).subscribe(onNext: { questions in
            self.setDisplay(questionDetail: questions.first!)
        }).disposed(by: disposeBag)
        
        // 画面リアルタイム値とDB処理管理をviewModel側に移行
        let viewModel = DetailOthersQuestionViewModel(
            input: answerSegment.rx.value.asObservable().map{ $0 + 1 },
            serverQuestionId: observableQuestion.first!.serverQuestionId!
        )
        
        answerButton.rx.tap.subscribe(onNext: { _ in
            if Date() > self.timeLimit {
                self.showAlert(title: "タイムオーバー", message: "時間制限を過ぎております")
                return
            }
        
            let alert = UIAlertController(title: "回答確認", message: "本当に回答しますか？", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default ) { (action: UIAlertAction) in
                self.indicator.startAnimating()
                self.answerButton.isEnabled = false
                viewModel.answer()
            }
            let ng = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(ng)
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        // DB処理結果イベント取得
        viewModel.answerResult.subscribe(onNext: { result in
            self.indicator.stopAnimating()
            self.answerButton.isEnabled = true
            if !result {
                self.showAlert(title: "エラー", message: "サーバとの通信に失敗しました")
                return
            }
            self.showAlert(title: "送信完了", message: "送信が完了しました")
        }).disposed(by: disposeBag)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setDisplay(questionDetail: Question) {
        questionView.text = questionDetail.question
        answer1View.text = questionDetail.answer1
        answer2View.text = questionDetail.answer2
        timeLimitLabel.text = Common.changeToLocalDateTime(target: questionDetail.timeLimit!)
        targetNumberLabel.text = String(questionDetail.targetNumber) + "人"
        
        //タイムリミットが過ぎていた場合
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.locale = Locale(identifier: "ja_JP")
        self.timeLimit = df.date(from: questionDetail.timeLimit!)
        
        answerButton.isHidden = !(questionDetail.decision == 0 && Date() <= timeLimit)
        answerSegment.isHidden = questionDetail.decision == 0 && Date() > timeLimit
        answerSegment.isEnabled = questionDetail.decision == 0
        
        if questionDetail.decision == 0 && Date() > timeLimit {
            yourChoiceLabel.text = "Over..."
        }
        
        if !questionDetail.determinationFlag {
            return
        }
        
        answer1numView.text = String(questionDetail.answer1number) + "人"
        answer2numView.text = String(questionDetail.answer2number) + "人"
        let sum = questionDetail.answer1number + questionDetail.answer2number
        answer1perView.text = String(sum == 0 ? 0 : questionDetail.answer1number * 100 / sum) + "%"
        answer2perView.text = String(sum == 0 ? 0 : questionDetail.answer2number * 100 / sum) + "%"
    }
    
    //Headerが表示される時の処理
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        //Headerのラベルの文字色を設定
        header.textLabel?.textColor = UIColor.orange
        header.textLabel?.font = UIFont.systemFont(ofSize: 10)
        //Headerの背景色を設定
        header.contentView.backgroundColor = UIColor.darkGray
        header.isUserInteractionEnabled = true
    }
}
