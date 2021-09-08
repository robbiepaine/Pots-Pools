//
//  ProfileController.swift
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

class ProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate{
        
    var ownerId: String = ""
    var email: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var balanceAtRisk: String = ""
    var availBalance: String = ""
    var numActivePools: String = ""
    var numWins: String = ""
    var type: String = ""
    var funded: String = ""
    
    let myInfoView = UITableView()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let infoCell = tableView.dequeueReusableCell(withIdentifier: "infoCell") ?? UITableViewCell(style: .default, reuseIdentifier: "infoCell")
        infoCell.selectionStyle = .none
        
        if indexPath.row == 0 {
            infoCell.textLabel?.text = "Balance at Risk: $" + balanceAtRisk
        }else if indexPath.row == 1 {
            infoCell.textLabel?.text = "Available Balance: $" + availBalance
        }else if indexPath.row == 2 {
            infoCell.textLabel?.text = "Number of Active Pools: " + numActivePools
        }else if indexPath.row == 3 {
            infoCell.textLabel?.text = "Number of Wins: " + numWins
        }else if indexPath.row == 4 {
            infoCell.textLabel?.text = "User ID: " + userId!
        }else if indexPath.row == 5 {
            infoCell.textLabel?.text = "Manage Payment Methods"
        }
    
        //cell.accessoryType = item.checked ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        return infoCell
    }
    
    var username: String?
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.topAnchor, paddingTop: 75, width: 100, height: 100)
        
        profileImageView.layer.cornerRadius = 100/2
        
        view.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.anchor(top: profileImageView.bottomAnchor,paddingTop: 12)
        
        view.addSubview(emailLabel)
        emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailLabel.anchor(top: nameLabel.bottomAnchor,paddingTop: 4)
        
        return view
    }()
    
    private var userId: String? {
        return stitch.auth.currentUser?.id
    }
    
    let messageButton: UIButton = {
       let button = UIButton(type: .system)
       button.setImage(#imageLiteral(resourceName: "ic_person_outline_white_2x").withRenderingMode(.alwaysOriginal), for: .normal)
       button.addTarget(self, action: #selector(handleMessageUser), for: .touchUpInside)
    return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "Image")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = .red
        return iv
    }()
    
    var userData = [UserItem]() // our table view data source
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshView()
        
        view.backgroundColor = .white
        
        view.addSubview(containerView)
        
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 250)

        self.myInfoView.dataSource = self
        self.myInfoView.delegate = self
        view.addSubview(self.myInfoView)
        myInfoView.frame = CGRect(x: 0, y: 250, width: self.view.frame.width, height: self.view.frame.height-250)
        
        let newFundsButton = UIButton(frame: .zero)
        newFundsButton.frame = CGRect(origin: CGPoint(x: (view.bounds.width / 2.0) - (view.bounds.width * 0.70) / 2 ,y : view.bounds.height - (view.bounds.height / 6.0)), size: CGSize(width: view.bounds.width * 0.60, height: 50))
        newFundsButton.backgroundColor = .blue
        newFundsButton.layer.cornerRadius = 25
        
        newFundsButton.setTitle("Free $100!", for: .normal)
        newFundsButton.addTarget(self, action: #selector(self.addFunds), for: .touchUpInside)
        view.addSubview(newFundsButton)
        
        configureUI()
    }
    
    func userInfo() {
     
        firstName = userData[0].firstName
        lastName = userData[0].lastName
        email = userData[0].email
        password = userData[0].email
        email = userData[0].email
        balanceAtRisk = String(format: "%.02f", userData[0].balanceAtRisk)
        availBalance = String(format: "%.02f", userData[0].availBalance)
        numActivePools = String(userData[0].numActivePools)
        numWins = String(userData[0].numWins)
        funded = userData[0].funded
        
        nameLabel.text = firstName + " " + lastName
        emailLabel.text = email
        
    }

    @objc func addFunds(sender: UIButton!){
        let query : Document = ["_id": self.userId!];
        let newInfo : Document = ["$inc": ["availBalance": 100] as Document];
        let options = RemoteUpdateOptions(upsert: true);
        usersCollection?.updateOne(filter: query, update: newInfo, options: options) {result in
            switch result {
            case .failure(let e):
                print("error adding funds , \(e.localizedDescription)")
                DispatchQueue.main.async {
                }
            case .success:
                print("Successfully updated balance")
                DispatchQueue.main.async {
                    self.refreshView()
                }
            }
        }
    }
    
    
    
    // Refresh the Profile
    func refreshView(){
        if stitch.auth.isLoggedIn {
            usersCollection?.find(["_id": [ "$eq": self.userId!] as Document]).toArray ({ result in
                switch result {
                case .success(let users):
                    self.userData = users
                    print("userdata, \(String(describing: self.userData))")
                    DispatchQueue.main.async {
                        self.userInfo()
                        self.myInfoView.reloadData()
                    }
                case .failure(let e):
                    print("error, \(e))")
                    //fatalError(e.localizedDescription)
                }
            })
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }

    func configureUI(){
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = .darkGray
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Profile"
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_3x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    @objc func handleMessageUser() {
        print("Messgage User")
    }
      
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat? = 0, paddingLeft: CGFloat? = 0, paddingBottom: CGFloat? = 0, paddingRight: CGFloat? = 0, width: CGFloat? = nil, height: CGFloat? = nil){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop!).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft!).isActive = true
        }
        
        if let bottom = bottom {
            if let paddingBottom = paddingBottom {
                bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            }
        }
        
        if let right = right {
            if let paddingRight = paddingRight {
                rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            }
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
