//
//  IndicatorViewController.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/10.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import RealmSwift

class IndicatorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let disposeBag = DisposeBag()
        NotificationCenter.default.rx.notification(Notification.Name("finishIndicator"))
            .subscribe(onNext: { _ in
                print("受信成功")
                self.dismiss(animated: true, completion: nil)
                }
                , onError: { _ in
                    print("error")
                }
                , onCompleted: {
                    print("complete")
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.post(name: Notification.Name("openIndicator"), object: nil, userInfo: nil)
        print("ローディング開始")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
