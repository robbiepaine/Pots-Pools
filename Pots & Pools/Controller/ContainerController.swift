//
//  ContainerController.swift
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

class ContainerController: UIViewController {

    var menuController: MenuController!
    var centerController: UIViewController!
    var homePoolsController: HomePoolsController!
    var isExpanded = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle{return .lightContent}
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{return .slide}
    override var prefersStatusBarHidden: Bool {return false}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePoolController()
    }
    
    func configureHomeController(){
        }
    
    func configurePoolController(){
        let homePoolsController = HomePoolsController()

        homePoolsController.delegate = self
        centerController = UINavigationController(rootViewController: homePoolsController)
    
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    func configureMenuController(){
        if menuController == nil {
            menuController = MenuController()
            menuController.delegate = self
            view.insertSubview(menuController.view, at: 0)
            addChild(menuController)
            menuController.didMove(toParent: self)
        }
    }

    func animatePanel(shouldExpand: Bool, menuOption: MenuOption?){
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                print("menu selected")
                self.centerController.view.frame.origin.x = 200
                //self.homePoolsController.view.frame.origin.x = self.homePoolsController.view.frame.width - 200
            },completion:nil)
        } else {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerController.view.frame.origin.x = 0
        }) { (_) in
            guard let menuOption = menuOption else { return }
            self.didSelectMenuOption(menuOption: menuOption)
            }
        }
        animateStatusBar()
    }
    
    func didSelectMenuOption(menuOption: MenuOption){
        switch menuOption {
        case .Balance:
            print("show balance")
        case .Blank:
            print("nothing to see here")
        case .Profile:
            let proController = ProfileController()
            //controller.username =
            present(UINavigationController(rootViewController: proController), animated: true, completion: nil)
        case .Inbox:
            print("Show Inbox")
        case .History:
            let histController = HistoryTableViewController()
            //controller.username =
            present(UINavigationController(rootViewController: histController), animated: true, completion: nil)
        case .Settings:
            let setController = SettingsController()
            //controller.username =
            present(UINavigationController(rootViewController: setController), animated: true, completion: nil)
        case .Logout:
            logout(self)
        }
    }
    
    @objc func logout(_ sender: Any) {
        stitch.auth.logout { result in
            switch result {
            case .failure(let e):
                print("Had an error logging out: \(e)")
            case .success:
                DispatchQueue.main.async {
                    print("SUCCESS")
                    //let logController = LandingController()
                    //logController.modalPresentationStyle = .overCurrentContext
                    //self.navigationController?.popToViewController(animated: true)
                    //self.navigationController?.pushViewController(logController, animated: true)
                    self.dismiss(animated: true, completion: nil)
                    //self.show(logController, sender: self)
                }
            }
        }
    }
    
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
        self.setNeedsStatusBarAppearanceUpdate()
        },completion:nil)
    }
}


extension ContainerController: HomePoolsControllerDelegate {
    
    func handleMenuToggle(forMenuOption menuOption: MenuOption?){
        
        if !isExpanded{
            configureMenuController()
        }
        
        isExpanded = !isExpanded
        animatePanel(shouldExpand: isExpanded, menuOption: menuOption)
    }
    
}
