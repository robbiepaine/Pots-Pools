//
//  SettingsController.swift
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

class SettingsController: UIViewController {
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        if let username = username {
            print("username is \(username)")
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureUI(){
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = .darkGray
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_3x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
}
