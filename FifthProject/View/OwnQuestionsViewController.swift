//
//  OwnQuestionsTableViewController.swift
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
import RxRealm

class OwnQuestionsViewController: UITableViewController {
    var questionList: Results<Question>!
    let realm = try! Realm()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = TokenMonitoringService()
//        let _ = NetworkMonitoringService()
        
        self.questionList = realm.objects(Question.self)
            .filter("owner == %@", Constant.own)
            .filter("deleteFlag == %@", false)
            .sorted(byKeyPath: "id", ascending: false)
        
        Observable.collection(from: questionList).subscribe(onNext: { _ in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        let swipeL = UISwipeGestureRecognizer()
        swipeL.direction = .left
        swipeL.numberOfTouchesRequired = 1
        swipeL.addTarget(self, action: #selector(self.swipeLeft(sender:)))
        self.view.addGestureRecognizer(swipeL)
    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.questionList.count
    }
    
    @objc func swipeLeft(sender:UISwipeGestureRecognizer) {
        self.tabBarController?.selectedIndex = 1
    }
    
//    // Cell の高さを１２０にする
//    func tableView(_ table: UITableView,
//                   heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120.0
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ownQuestionCell", for: indexPath)
        
        let submitDateTimeLabel = cell.viewWithTag(1) as! UILabel
        submitDateTimeLabel.text = Common.changeToLocalDateTime(target: questionList[indexPath.row].createdDateTime)
        
        let askingLabel = cell.viewWithTag(2) as! UILabel
        askingLabel.isHidden = questionList[indexPath.row].determinationFlag
        
        let determinationLabel = cell.viewWithTag(3) as! UILabel
        determinationLabel.isHidden = !(questionList[indexPath.row].determinationFlag && !questionList[indexPath.row].confirmationFlag)
        
        let timeLimitLabel = cell.viewWithTag(4) as! UILabel
        timeLimitLabel.text = String(questionList[indexPath.row].timePeriod) + questionList[indexPath.row].timeUnit
        
        let targetNumberLabel = cell.viewWithTag(5) as! UILabel
        targetNumberLabel.text = String(questionList[indexPath.row].targetNumber) + "人"
        
        let questionView = cell.viewWithTag(6) as! UITextView
        questionView.text = questionList[indexPath.row].question

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        moveToDetailView(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let questionId = questionList[indexPath.row].id
            let question = self.realm.objects(Question.self).filter("id == %@", questionId).first!
            try! self.realm.write {
                question.deleteFlag = true
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        moveToDetailView(indexPath: indexPath)
    }
    
    func moveToDetailView(indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "DetailOwnQuestionViewController") as! DetailOwnQuestionViewController
        nextView.questionId = questionList[indexPath.row].id
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
