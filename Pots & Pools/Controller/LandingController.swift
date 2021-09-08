//
//  LandingController.swift
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

class LandingController: UIViewController {
    
    @IBOutlet weak var user: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    var ownerId: String = ""
    var email: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var balanceAtRisk: Double = 0
    var availBalance: Double = 0
    var numActivePools: Int = 0
    var numWins: Int = 0
    var type: String = ""
    var funded: String = ""
    
    var userData = [UserItem]() // our table view data source
    var centerController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    func assignbackground(){
        let background = UIImage(named: "gradient.jpg")

        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        }

    //Get User ID
    var userId: String? {
        return stitch.auth.currentUser?.id
    }
    
    @IBAction func continueButton(_ sender: Any) {
        
        if user.text == "" || pass.text == ""{
            let alertController = UIAlertController(title: "Enter Username/Password", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true, completion: nil)
        }else{
            stitch.auth.login(withCredential: UserPasswordCredential(withUsername: user.text ?? "username", withPassword: pass.text ?? "password")) { (result) in
                switch result {
                case .failure(let e):
                    print("error logginig in, \(e.localizedDescription)")
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Invalid Username/Password", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self.present(alertController, animated: true, completion: nil)
                    }
                case .success:
                    DispatchQueue.main.async {
                        let newController = ContainerController()
                        newController.modalPresentationStyle = .overCurrentContext
                        self.present(newController, animated: true,completion: nil)
                        self.user.text = ""
                        self.pass.text = ""
                    }
                }
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {

        let emailPassClient = stitch.auth.providerClient(
          fromFactory: userPasswordClientFactory
        )
        let newFalseAlertController = UIAlertController(title: "Updating Info Failed", message: nil, preferredStyle: .alert)
        newFalseAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let needDataAlertController = UIAlertController(title: "Must fill all fields", message: nil, preferredStyle: .alert)
        needDataAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let needPwdAlertController = UIAlertController(title: "Password must be between 6-23 characters", message: nil, preferredStyle: .alert)
        needPwdAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let alertController = UIAlertController(title: "Sign Up", message: nil, preferredStyle: .alert)
        alertController.addTextField { mail in
            mail.placeholder = "Username"
        }
        alertController.addTextField { pass in
            pass.placeholder = "Password"
        }
        alertController.addTextField { first in
            first.placeholder = "First Name"
        }
        alertController.addTextField { last in
            last.placeholder = "Last Name"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            if let newEmail = alertController.textFields?[0].text, let newPassword = alertController.textFields?[1].text, let newFirstName = alertController.textFields?[2].text, let newLastName = alertController.textFields?[3].text{
                        if newEmail != "" && newPassword != "" && newFirstName != "" && newLastName != "" {
                            if newPassword.count > 5 && newPassword.count < 24{
                            emailPassClient.register(withEmail: newEmail, withPassword: newPassword) { result in
                                      switch result {
                                case .failure(let e):
                                    print("error registering new account: , \(e.localizedDescription)")
                                    DispatchQueue.main.async {
                                    }
                                case .success:
                                    print("Success creating new account")
                                    stitch.auth.login(withCredential: UserPasswordCredential(withUsername: newEmail, withPassword: newPassword)) { (result) in
                                        switch result {
                                        case .failure(let e):
                                            print("error logginig in to new account: , \(e.localizedDescription)")
                                            DispatchQueue.main.async {
                                            }
                                        case .success:
                                            let query : Document = ["_id": self.userId!];
                                            let newInfo : Document = ["$set": ["email": newEmail, "password": newPassword, "firstName": newFirstName,"lastName": newLastName, "balanceAtRisk": 0,"availBalance": 0,"numActivePools": 0,"numWins": 0,"funded": ""] as Document];
                                            let options = RemoteUpdateOptions(upsert: true);
                                            usersCollection?.updateOne(filter: query, update: newInfo, options: options) {result in
                                                switch result {
                                                case .failure(let e):
                                                    print("error adding info to databse: , \(e.localizedDescription)")
                                                    DispatchQueue.main.async {
                                                    }
                                                case .success:
                                                    print("Successfully updated Database")
                                                    DispatchQueue.main.async {
                                                        let newController = ContainerController()
                                                        newController.modalPresentationStyle = .overCurrentContext
                                                        self.present(newController, animated: true,completion: nil)
                                                        self.user.text = ""
                                                        self.pass.text = ""
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            }else{self.present(needPwdAlertController, animated: true, completion: nil)}
                        }else{self.present(needDataAlertController, animated: true, completion: nil)}
            }}))
        self.present(alertController, animated: true, completion: nil)
    }
}
