//
//  CreateQuestionViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

class CreateQuestionTableViewController: UITableViewController {

//    @IBOutlet weak var questionSection: UITableViewSection!
    @IBOutlet weak var questionView: UITextView!
    @IBOutlet weak var answer1View: UITextView!
    @IBOutlet weak var answer2View: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var targetNumberPickerView: UIPickerView!
    @IBOutlet weak var timeUnitPickerView: UIPickerView!
    @IBOutlet weak var timePeriodPickerView: UIPickerView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        targetNumberPickerView.tag = 0
        timeUnitPickerView.tag = 1
        timePeriodPickerView.tag = 2
        
        Observable.just(Singleton.targetNumbers)
            .bind(to: targetNumberPickerView.rx.itemTitles) { _, targetNumber in
                return String(targetNumber)
            }
            .disposed(by: disposeBag)
        
        Observable.just(Singleton.timeUnits)
            .bind(to: timeUnitPickerView.rx.itemTitles) { _, unit in
                return unit
            }
            .disposed(by: disposeBag)
        
        let viewModel = CreateQuestionViewModel(input: (
            question: questionView.rx.text.orEmpty.asObservable(),
            answer1: answer1View.rx.text.orEmpty.asObservable(),
            answer2: answer2View.rx.text.orEmpty.asObservable(),
            targetNumber: targetNumberPickerView.rx.modelSelected(Int.self).asObservable().map{ $0.first! },
            timePeriod: timePeriodPickerView.rx.modelSelected(Int.self).asObservable().map{ $0.first! },
            timeUnit: timeUnitPickerView.rx.modelSelected(String.self).asObservable().map{ $0.first! }
            )
        )
        
        viewModel.timePeriodArray.bind(to: timePeriodPickerView.rx.itemTitles) { _, minute in
            return String(minute)
            }
            .disposed(by: disposeBag)
        viewModel.insertQuestioin.bind(to: questionView.rx.text).disposed(by: disposeBag)
        viewModel.insertAnswer1.bind(to: answer1View.rx.text).disposed(by: disposeBag)
        viewModel.insertAnswer2.bind(to: answer2View.rx.text).disposed(by: disposeBag)
        
        targetNumberPickerView.selectRow(2, inComponent: 0, animated: true)
        timePeriodPickerView.selectRow(4, inComponent: 0, animated: true)
        
        submitButton.rx.tap.subscribe(
            onNext: { _ in
                if !viewModel.isValid.value {
                    self.showAlert(title: "入力エラー", message: "入力していない項目があります")
                    return
                }
                
                let alert = UIAlertController(title: "送信確認", message: "本当に送信しますか？", preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default ) { (action: UIAlertAction) in
                    self.submitButton.rx.isEnabled.onNext(false)
                    self.indicator.startAnimating()
                    viewModel.submitQuestion()
                }
                let ng = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(ok)
                alert.addAction(ng)
                self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.submitResult.subscribe(onNext: { result in
                self.indicator.stopAnimating()
                self.submitButton.rx.isEnabled.onNext(true)
                if !result {
                    self.showAlert(title: "エラー", message: "サーバとの通信に失敗しました")
                    return
                }
                self.showAlert(title: "送信完了", message: "送信が完了しました")
            }
            , onError: { _ in
                print("error")
            }
            , onCompleted: {
                print("complete")
        }).disposed(by: self.disposeBag)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func swipeLeft(sender:UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex = 3
    }
    
    @objc func swipeRight(sender:UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func tapHeader(sender: UITapGestureRecognizer) {
        hideKeyboard()
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
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader(sender:))))
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
