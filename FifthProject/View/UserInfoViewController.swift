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
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authentication.text = Auth.auth().currentUser?.email ?? Auth.auth().currentUser?.phoneNumber
        
        regionPickerView.tag = 0
        regionPickerView.setValue(UIColor.white, forKey: "textColor")
        agePickerView.tag = 1
        agePickerView.setValue(UIColor.white, forKey: "textColor")
        
        Observable.just(Singleton.regions)
            .bind(to: regionPickerView.rx.itemTitles) { _, region in
                return region
            }
            .disposed(by: disposeBag)
        
        Observable.just(Singleton.ages)
            .bind(to: agePickerView.rx.itemTitles) { _, age in
                return String(age)
            }
            .disposed(by: disposeBag)
        
        let viewModel = RegistrationViewModel(input: (
            //            id: authentication.rx.text.orEmpty.asObservable(),
            region: regionPickerView.rx.modelSelected(String.self).asObservable().map{x in return x.first!},
            age: agePickerView.rx.modelSelected(Int.self).asObservable().map{x in return x.first!}
            )
        )
        
        let realm = try! Realm()
        regionPickerView.selectRow(Singleton.regions.firstIndex(of: realm.objects(User.self).first!.region)!, inComponent: 0, animated: true)
        agePickerView.selectRow(Singleton.ages.firstIndex(of: realm.objects(User.self).first!.age)!, inComponent: 0, animated: true)

        let swipeR = UISwipeGestureRecognizer()
        swipeR.direction = .right
        swipeR.numberOfTouchesRequired = 1
        swipeR.addTarget(self, action: #selector(self.swipeRight(sender:)))
        self.view.addGestureRecognizer(swipeR)
        
        updateButton.rx.tap.subscribe(
            onNext: { _ in
                let alert = UIAlertController(title: "登録確認", message: "本当に登録しますか？", preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default ) { (action: UIAlertAction) in
                    if viewModel.updateUser().result {
                        self.showAlert(title: "更新完了", message: "更新に成功しました")
                        return
                    }
                    self.showAlert(title: "エラー", message: viewModel.registerUser().errMessage)
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
            return Singleton.regions.count
        }
        return Singleton.ages.count
    }
    
//    // UIPickerViewの最初の表示
//    func pickerView(_ pickerView: UIPickerView,
//                    titleForRow row: Int,
//                    forComponent component: Int) -> String? {
//        let realm = try! Realm()
//        let myInfo = realm.objects(User.self)
//        if (pickerView.tag == 0){
//            return  myInfo.first!.region
//        }
//        return String(myInfo.first!.age)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
