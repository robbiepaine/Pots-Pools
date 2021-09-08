//
//  MenuController.swift
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

private let reuseIdentifier = "MenuOptionCell"

class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var balLabel = "TBD"
    
    var tableView: UITableView!
    var delegate: HomePoolsControllerDelegate?
    
    override func viewDidLoad() {
        configureTableView()
        tableView.reloadData()
    }
    
    func configureTableView(){
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(MenuOptionCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .darkGray
        tableView.separatorStyle = .none
        tableView.rowHeight = 50

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }

//extension MenuController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for:indexPath) as! MenuOptionCell
        
        let menuOption = MenuOption(rawValue:indexPath.row)
        cell.descriptionlabel.text = menuOption?.description
        cell.descriptionlabel.font = .boldSystemFont(ofSize: 15)
        cell.iconImageView.image = menuOption?.image
        if indexPath.row == 0{
            cell.descriptionlabel.text = "Balance: $" + balLabel
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuOption = MenuOption(rawValue:indexPath.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
}
