//
//  RegistrationViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/06.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

class RegistrationViewController : UIViewController {
    
//    @IBOutlet weak var regionLabel: UILabel!0
    @IBOutlet weak var authentication: UILabel!
    @IBOutlet weak var regionPickerView: UIPickerView!
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBOutlet weak var registerButton: UIButton!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authentication.text = Auth.auth().currentUser?.email ?? Auth.auth().currentUser?.phoneNumber
        
        regionPickerView.tag = 0
        agePickerView.tag = 1
        
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
            region: regionPickerView.rx.modelSelected(String.self).asObservable().map{ $0.first! },
            age: agePickerView.rx.modelSelected(Int.self).asObservable().map{ $0.first! }
            )
        )
        
//        viewModel.insertUserId.bind(to: authentication.rx.text).disposed(by: disposeBag)
        
        registerButton.rx.tap.subscribe(
            onNext: { _ in
                let alert = UIAlertController(title: "登録確認", message: "本当に登録しますか？", preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default ) { (action: UIAlertAction) in
                    let resultObj = viewModel.registerUser()
                    if resultObj.result {
                        self.performSegue(withIdentifier: "toMainView", sender: nil)
                        return
                    }
                    self.showAlert(title: "エラー", message: resultObj.errMessage)
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    
//    // UIPickerViewの列の数
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    // UIPickerViewの行数、リストの数
//    func pickerView(_ pickerView: UIPickerView,
//                    numberOfRowsInComponent component: Int) -> Int {
//        if (pickerView.tag == 0){
//            return Singleton.regions.count
//        }
//        return Singleton.ages.count
//    }
//
//    // UIPickerViewの最初の表示
//    func pickerView(_ pickerView: UIPickerView,
//                    titleForRow row: Int,
//                    forComponent component: Int) -> String? {
//        if (pickerView.tag == 0){
//            return  Singleton.regions[row]
//        }
//        return String(Singleton.ages[row])
//    }
}
