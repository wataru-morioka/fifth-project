//
//  UserInfoViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/09.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import RealmSwift

class UserInfoViewController: UIViewController {

    @IBOutlet weak var authentication: UILabel!
    @IBOutlet weak var regionPickerView: UIPickerView!
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    let disposeBag = DisposeBag()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // google認証によって取得したユーザアカウント情報を画面にセット
        authentication.text = Auth.auth().currentUser?.email ?? Auth.auth().currentUser?.phoneNumber
        
        regionPickerView.tag = 0
        agePickerView.tag = 1
        
        // 右スワイプ処理登録
        let swipeR = UISwipeGestureRecognizer()
        swipeR.direction = .right
        swipeR.numberOfTouchesRequired = 1
        swipeR.addTarget(self, action: #selector(self.swipeRight(sender:)))
        self.view.addGestureRecognizer(swipeR)
        
        // 地域リストをpickerビューにバインド
        Observable.just(Constant.regions)
            .bind(to: regionPickerView.rx.itemTitles) { _, region in
                return region
            }
            .disposed(by: disposeBag)
        // 年齢リストをpickerビューにバインド
        Observable.just(Constant.ages)
            .bind(to: agePickerView.rx.itemTitles) { _, age in
                return String(age)
            }
            .disposed(by: disposeBag)
        
        // 画面リアルタイム値とDB処理管理をviewModel側に移行
        let viewModel = RegistrationViewModel(input: (
            region: regionPickerView.rx.modelSelected(String.self).asObservable().map{x in return x.first!},
            age: agePickerView.rx.modelSelected(Int.self).asObservable().map{x in return x.first!}
            )
        )
        
        // 初期値セット
        regionPickerView.selectRow(Constant.regions.firstIndex(of: self.realm.objects(User.self).first!.region)!, inComponent: 0, animated: true)
        agePickerView.selectRow(Constant.ages.firstIndex(of: self.realm.objects(User.self).first!.age)!, inComponent: 0, animated: true)
        
        updateButton.rx.tap.subscribe(
            onNext: { _ in
                let alert = UIAlertController(title: "登録確認", message: "本当に登録しますか？", preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default ) { (action: UIAlertAction) in
                    self.updateButton.rx.isEnabled.onNext(false)
                    self.indicator.startAnimating()
                    viewModel.updateUser()
                }
                let ng = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(ok)
                alert.addAction(ng)
                self.present(alert, animated: true, completion: nil)
            }
            , onError: { _ in
                print("error")
                self.showAlert(title: "エラー", message: "サーバに接続できません")
            }
            , onCompleted: {
                print("complete")
        }).disposed(by: disposeBag)
        
        // DB処理結果イベント取得
        viewModel.updateResult.subscribe(onNext: { result in
                self.updateButton.rx.isEnabled.onNext(true)
                self.indicator.stopAnimating()
                if !result {
                    self.showAlert(title: "エラー", message: "サーバとの通信に失敗しました")
                    return
                }
                self.showAlert(title: "更新完了", message: "更新に成功しました")
            }
            , onError: { _ in
                print("error")
            }
            , onCompleted: {
                print("complete")
        }).disposed(by: self.disposeBag)
    }
    
    @objc func swipeRight(sender:UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex = 2
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0){
            return Constant.regions.count
        }
        return Constant.ages.count
    }
    
    // 画面から非表示になる直後に呼ばれます。
    // viewDidLoadとは異なり毎回呼び出されます。
    override func viewDidDisappear(_: Bool) {
//        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        regionPickerView.selectRow(Constant.regions.firstIndex(of: self.realm.objects(User.self).first!.region)!, inComponent: 0, animated: true)
        agePickerView.selectRow(Constant.ages.firstIndex(of: self.realm.objects(User.self).first!.age)!, inComponent: 0, animated: true)
    }
}
