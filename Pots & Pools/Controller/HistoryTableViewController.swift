//
//  newTableViewController.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/28/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

import UIKit
import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

class HistoryTableViewController:
UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //var delegate: HistoryTableViewController?
    
    let tableView = UITableView() // Create our tableview
    fileprivate var todoItems = [TodoItem]() // our table view data source
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureUI(){
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = .darkGray
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "My Pools"
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_3x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    

    private var userId: String? {
        return stitch.auth.currentUser?.id
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        // check to make sure a user is logged in
        // if they are, load the user's todo items and refresh the tableview
        if stitch.auth.isLoggedIn {
            itemsCollection.find(["all participants": [ "$eq": self.userId!] as Document]).toArray { result in
                switch result {
                case .success(let todos):
                    self.todoItems = todos
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let e):
                    fatalError(e.localizedDescription)
                }
            }
        } else {
            // no user is logged in, send them back to the welcome view
            self.navigationController?.setViewControllers([ContainerController()], animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your Pool History"

        self.tableView.dataSource = self
        self.tableView.delegate = self
        view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        //self.tableView.frame = CGRect(x: 0 , y: self.view.frame.height * 0.1, width: self.view.frame.width, height: self.view.frame.height * 0.9)
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(self.addTodoItem(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        configureUI()
    }
    
    // LOGOUT BUTTON
    @objc func logout(_ sender: Any) {
        stitch.auth.logout { result in
            switch result {
            case .failure(let e):
                print("Had an error logging out: \(e)")
            case .success:
                DispatchQueue.main.async {
                    self.navigationController?.setViewControllers([ContainerController()], animated: true)
                }
            }
        }
    }
    
    // ADD
    @objc func addTodoItem(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Pool", message: nil, preferredStyle: .alert)
        alertController.addTextField { name in
            name.placeholder = "Pool Name"
        }
        alertController.addTextField { num in
            num.placeholder = "Number of Participants"
        }
        alertController.addTextField { amountPer in
            amountPer.placeholder = "$ Amount Per Person "
        }
        alertController.addTextField { funding in
            funding.placeholder = "Funding Date (mm/dd/yy)"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let task = alertController.textFields?[0].text, let participants = alertController.textFields?[1].text, let amountNum = alertController.textFields?[2].text,let funding = alertController.textFields?[3].text{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy"
                let fundDate = dateFormatter.date(from: funding)

                let amountFinal = Double(amountNum) as Double?
                let unfundedAmt = Int(amountNum)! * Int(participants)!
                let winnerText = ""
                let todoItem = TodoItem(id: ObjectId(),
                                        ownerId: self.userId!,
                                        //ownerId: "5d672d63d2e96982b04c969f",
                                        amount: Double(amountFinal ?? 0.0),
                                        funded: 0,
                                        unfunded: Double(unfundedAmt),
                                        participants: Int(participants) ?? 0,
                                        allParticipants: [self.userId!],
                                        paidParticipants: [],
                                        unpaidParticipants: [self.userId!],
                                        fundingDate: fundDate ?? Date(),
                                        createdDate: Date(),
                                        task: task,
                                        winner: winnerText,
                                        checked: false)
                // optimistically add the item and reload the data
                self.todoItems.append(todoItem)
                self.tableView.reloadData()
                itemsCollection.insertOne(todoItem) { result in
                    switch result {
                    case .failure(let e):
                        print("error inserting item, \(e.localizedDescription)")
                        // an error occured, so remove the newTableViewControllernd reload the data again to refresh the ui
                        DispatchQueue.main.async {
                            self.todoItems.removeLast()
                            self.tableView.reloadData()
                        }
                    case .success:
                        // no action necessary
                        print("successfully inserted a document")
                    }
                }
            }
        }))
        self.present(alertController, animated: true)
    }
    
    // EDITING FORMATTING
    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // SELECT/SWIPE
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var item = self.todoItems[indexPath.row]
        let title = item.checked ? NSLocalizedString("Undone", comment: "Undone") : NSLocalizedString("Done", comment: "Done")
        let action = UIContextualAction(style: .normal, title: title, handler: { _, _, completionHander in
            item.checked = !item.checked
            self.todoItems[indexPath.row] = item
            DispatchQueue.main.async {
                self.tableView.reloadData()
                completionHander(true)
            }
        })
        
        action.backgroundColor = item.checked ? .red : .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    // DELETE
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case .delete = editingStyle else { return }
        let falseAlertController = UIAlertController(title: "Owner Required!", message: "Only the Pool onwer has access to remove this pool.", preferredStyle: .alert)
        falseAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let item = todoItems[indexPath.row]
        if item.ownerId == self.userId! {
        itemsCollection.deleteOne(["_id": item.id]) { result in
            switch result {
            case .failure(let e):
                print("Error, could not delete: \(e.localizedDescription)")
            case .success:
                self.todoItems.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
            
        }else{
            self.present(falseAlertController, animated: true)
            
        }
    }
    
    // TABLE SETUP
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") ?? UITableViewCell(style: .default, reuseIdentifier: "TodoCell")
        cell.selectionStyle = .none
        let item = todoItems[indexPath.row]
        cell.textLabel?.text = item.task
        cell.accessoryType = item.checked ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        return cell
    }
    
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let row = indexPath.row
        let editController = EditPoolController()
        
        tableView.cellForRow(at: indexPath)?.selectionStyle = .blue
        //print("Selected:\(indexPath)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        //editController.poolOptions = todoItems[indexPath.row]
        editController.task = String(todoItems[indexPath.row].task)
        editController.winner = String(todoItems[indexPath.row].winner)
        editController.participants = todoItems[indexPath.row].participants
        editController.ownerId = String(todoItems[indexPath.row].ownerId)
        editController.createdDate = todoItems[indexPath.row].createdDate
        editController.fundingDate = todoItems[indexPath.row].fundingDate
        editController.amount = todoItems[indexPath.row].amount
        editController.amountFund = todoItems[indexPath.row].funded
        editController.amountUnfund = todoItems[indexPath.row].unfunded
        editController.paidParticipants = todoItems[indexPath.row].paidParticipants
        editController.unpaidParticipants = todoItems[indexPath.row].unpaidParticipants

        
        editController.headerTitle = tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "Selection"
        present(UINavigationController(rootViewController: editController), animated: true, completion: nil)
    }
    
    
    
}
