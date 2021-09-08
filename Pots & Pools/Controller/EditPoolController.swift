//
//  EditPoolController.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/26/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

import UIKit
import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

class EditPoolController: UIViewController, UITableViewDataSource {

    

    var username: String?
    var headerTitle: String = "Selection"
    let tableView = UITableView() // Create our tableview
    let payment = UIButton()
    
    var delegate: HistoryTableViewController?
    
    var ownerId: String = ""
    var amount: Double = 0.0
    var amountFund: Double = 0.0
    var amountUnfund: Double = 0.0
    var participants: Int = 0
    var allParticipants: Array<String> = []
    var paidParticipants: Array<String> = []
    var unpaidParticipants: Array<String> = []
    var fundingDate: Date = Date()
    var createdDate: Date = Date()
    var winner: String = ""
    var task: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self as? UITableViewDelegate
        view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_3x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))

        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                        target: self,
                                        action: #selector(self.editTodoItem(_:)))
        
        navigationItem.rightBarButtonItem = editButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        view.backgroundColor = .white
        
        configureUI()
        
        if let username = username {
            print("username is \(username)")
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let row = sender.tag
        print(String(row) + " Button tapped")
        
        // ADD PAYMENT CODE
        let alertController = UIAlertController(title: "Payment Completed", message: nil, preferredStyle: .alert)
        let falseAlertController = UIAlertController(title: "Payment Failed!", message: nil, preferredStyle: .alert)
        falseAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))

        let query : Document = ["task": task];
        let update : Document = ["$addToSet": ["paid participants": userId!] as Document];
        let update2 : Document = ["$pull": ["unpaid participants": userId!] as Document];
        let update3 : Document = ["$inc": ["funded": amount, "unfunded": -amount] as Document];
    
        let newInfo : Document = ["$inc": ["availBalance": -amount,"numActivePools": 1,"balanceAtRisk": amount] as Document];
        let me : Document = ["_id": self.userId!];
        
        let options = RemoteUpdateOptions(upsert: true);
        
        if !(paidParticipants.contains(userId!)) && (Int(amountFund) < (Int(amount) * Int(participants))) {
            itemsCollection?.updateOne(filter: query, update: update, options: options) { result in
                switch result {
                    case .failure(let error):
                        print("Failed to update: \(error)");
                    case .success(let result):
                        if !(result.modifiedCount == 0) {
                            usersCollection?.updateOne(filter: me, update: newInfo, options: options) {result in
                                switch result {
                                    case .failure(let e):
                                        print("error paying for pool , \(e.localizedDescription)")
                                    case .success:
                                        print("Successfully paid for pool")
                                        itemsCollection?.updateOne(filter: query, update: update2, options: options) { result in
                                            switch result {
                                                case .failure(let error):
                                                    print("Failed to update: \(error)");
                                                case .success(let result):
                                                    if !(result.modifiedCount == 0) {
                                                        print(result.modifiedCount)
                                                        print(result)
                                                        itemsCollection?.updateOne(filter: query, update: update3, options: options) { result in
                                                            switch result {
                                                                case .failure(let error):
                                                                    print("Failed to update: \(error)");
                                                                case .success(let result):
                                                                    if !(result.modifiedCount == 0) {
                                                                        print(result.modifiedCount)
                                                                        print(result)
                                                                        DispatchQueue.main.async {
                                                                            self.tableView.reloadData()
                                                                        }
                                                                    } else {self.present(falseAlertController, animated: true)}
                                                            }
                                                        }
                                                    }else{DispatchQueue.main.async{self.present(falseAlertController, animated: true)}}
                                            }
                                        }
                                }
                            }
                        }else{self.present(falseAlertController, animated: true)}
                }
            }
        self.present(alertController, animated: true)
        }else{self.present(falseAlertController, animated: true)}
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureUI(){
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = .darkGray
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = headerTitle
        navigationController?.navigationBar.barStyle = .black


    }
    
    private var userId: String? {
        return stitch.auth.currentUser?.id
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") ?? UITableViewCell(style: .default, reuseIdentifier: "TodoCell")
        cell.selectionStyle = .none
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let createDate = dateFormatter.string(from: createdDate)
        let fundDate = dateFormatter.string(from: fundingDate)

        if indexPath.row == 0{

            cell.textLabel?.text = "Pool Name: " + task
        }else if indexPath.row == 1{

            cell.textLabel?.text = "Created By: " + String(ownerId)
        }else if indexPath.row == 2{
            
            cell.textLabel?.text = "Number of Participants: " + String(participants)
        }else if indexPath.row == 3{
    
            cell.textLabel?.text = "Amount Per Participant: " + String(amount)
        }else if indexPath.row == 4{
            
            cell.textLabel?.text = "Amount Funded: " + String(amountFund)
        }else if indexPath.row == 5{
            
            cell.textLabel?.text = "Amount Unfunded: " + String(amountUnfund)
        }else if indexPath.row == 6{
            
            cell.textLabel?.text = ""
            payment.frame = CGRect(origin: CGPoint(x: 40,y :60), size: CGSize(width: 200, height: 24))
            payment.backgroundColor = .blue
            payment.setTitle("Pay", for: .normal)
            payment.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
            payment.tag = indexPath.row
            
            let cellHeight: CGFloat = 44.0
            payment.center = CGPoint(x: view.bounds.width / 2.0, y: cellHeight / 2.0)
            cell.addSubview(payment)
        }else if indexPath.row == 7{
            
            cell.textLabel?.text = "Funding On: " + fundDate
        }else if indexPath.row == 8{
            
            var paidStr = "Paid Participants: "
            for part in paidParticipants {
                 paidStr = paidStr + "\n" + part
            }
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = paidStr
            cell.translatesAutoresizingMaskIntoConstraints = false
        }else if indexPath.row == 9{
            
            var unpaidStr = "Unpaid Participants: "
            for uPart in unpaidParticipants {
                unpaidStr = unpaidStr + "\n" + uPart
            }
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = unpaidStr
            cell.translatesAutoresizingMaskIntoConstraints = false
        }else if indexPath.row == 10{
            
            cell.textLabel?.text = "Created On: " + createDate
        }else if indexPath.row == 11{
            
            cell.textLabel?.text = "Winner: " + String(winner)
        }else{
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    @objc func editTodoItem(_ sender: Any) {
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                        target: self,
                                        action: #selector(self.editTodoItem(_:)))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: self,
                                        action: #selector(self.editTodoItem(_:)))
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem? = tableView.isEditing ? doneButton : editButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }

}
