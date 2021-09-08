//
//  HomePoolsController.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/29/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

import UIKit
import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

class HomePoolsController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource  {

    var tableController: HistoryTableViewController!
    var homePoolsController: HomePoolsController!
    var delegate: HomePoolsControllerDelegate?
    var participants: Int = 0
    var allParticipants: Array<String> = []
    //var bColor: UIColor = UIColor(hue: 255, saturation: 255, brightness: 255, alpha: 1.0)
    var bColor = UIImage(named: "sunrise-photo.jpg")
    let currentTime = Date()
    
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
    
    var userData = [UserItem]() // our table view data source
    fileprivate var data = [TodoItem]() // our table view data source
    
    let progressColor = [UIColor .green,UIColor .blue,UIColor .red,UIColor .yellow,UIColor .purple, UIColor .brown, UIColor .orange]
    var numPools = 3
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(HomePoolsCellCollectionView.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    let searchButton: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "searchImg")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.tintColor = .white
        return iv
    }()
    
    var dots : UIPageControl = UIPageControl(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignHomeBackground()
        configureNavigationBar()
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.anchor(top: view.topAnchor, paddingTop: 90, width: (view.bounds.width * 0.9), height: 440)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        let newPoolByIdButton = UIButton(frame: .zero)
        newPoolByIdButton.setImage((searchButton.image), for: .normal)
        newPoolByIdButton.frame = CGRect(origin: CGPoint(x: (view.bounds.width / 2.0) + ((view.bounds.width * 0.70) / 2)-50 ,y : view.bounds.height - (view.bounds.height / 8.0)-55), size: CGSize(width:60, height: 60))
        
        newPoolByIdButton.backgroundColor = .darkGray
        newPoolByIdButton.layer.cornerRadius = 30

        newPoolByIdButton.addTarget(self, action: #selector(self.newPoolByIdButtonAction), for: .touchUpInside)
        view.addSubview(newPoolByIdButton)
        
        let newPoolButton = UIButton(frame: .zero)
        newPoolButton.frame = CGRect(origin: CGPoint(x: (view.bounds.width / 2.0) - (view.bounds.width * 0.70) / 2 ,y : newPoolByIdButton.frame.origin.y), size: CGSize(width: 60, height: 60))
        newPoolButton.backgroundColor = .green
        newPoolButton.layer.cornerRadius = 30

        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = newPoolButton.frame.size
        gradientLayer.cornerRadius = 30
        gradientLayer.colors =
            [UIColor.white.cgColor,UIColor.green.withAlphaComponent(1).cgColor]
        newPoolButton.layer.addSublayer(gradientLayer)
        
        newPoolButton.setTitle("+", for: .normal)
        newPoolButton.titleLabel?.font = .systemFont(ofSize: 32, weight: .bold)
        newPoolButton.addTarget(self, action: #selector(self.newPoolGenButton), for: .touchUpInside)
        view.addSubview(newPoolButton)
        
        configurePageControl()
        refreshView()
        newUserInfo()
    }
    
    func assignHomeBackground(){
        let homeBack = UIImage(named: "sunrise-photo.jpg")

        var homeImgView : UIImageView!
        homeImgView = UIImageView(frame: view.bounds)
        homeImgView.contentMode =  UIView.ContentMode.scaleAspectFill
        homeImgView.clipsToBounds = true
        homeImgView.image = homeBack
        homeImgView.center = view.center
        view.addSubview(homeImgView)
        self.view.sendSubviewToBack(homeImgView)
    }
    
    func configurePageControl() {
        dots.numberOfPages = data.count
        dots.translatesAutoresizingMaskIntoConstraints = false
        dots.currentPageIndicatorTintColor = UIColor.orange
        dots.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.8)

        let leading = NSLayoutConstraint(item: dots, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: dots, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: dots, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -(view.bounds.height/3.1))

        dots.isUserInteractionEnabled = false
        dots.transform = CGAffineTransform(scaleX: 2, y: 2)
        view.insertSubview(dots, at: 0)
        view.bringSubviewToFront(dots)
        view.addConstraints([leading, trailing, bottom])
     }
    
    // ADD POOL BY ID
    @objc func newPoolByIdButtonAction(sender: UIButton!) {
        let alertController = UIAlertController(title: "Add Pool By Id", message: nil, preferredStyle: .alert)
        let tooManyAlertController = UIAlertController(title: "No Room!", message: "Check with the Pool creator to remove a player any try again.", preferredStyle: .alert)
        tooManyAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let falseAlertController = UIAlertController(title: "No Such Pool Exists!", message: "Check the Pool Id and try again.", preferredStyle: .alert)
        falseAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addTextField { tName in
            tName.placeholder = "Pool Name"
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
        if let task = alertController.textFields?[0].text{

        let query : Document = ["task": task];
            let update : Document = [
                "$addToSet": [
                    "all participants": self.userId!,
                    "unpaid participants": self.userId!
                    ] as Document];
                    //,"comment": "what a neat product"
            let options = RemoteUpdateOptions(upsert: true);
            itemsCollection?.updateOne(filter: query, update: update, options: options) { result in
            switch result {
            case .success(let result):
                if !(result.matchedCount == 0){
                    print(result.matchedCount)
                    print("Successfully added a new Pool.")
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } else {
                    print("Could not find a matching item.")
                    self.present(falseAlertController, animated: true)
                }
            case .failure(let error):
                print("Failed to update: \(error)");
            }
        }
        }
        }))
        self.present(alertController, animated: true)
        refreshView()
    }
    
    
    // ADD NEW
    @objc func newPoolGenButton(_ sender: Any) {
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
                //self.todoItems.append(todoItem)

                itemsCollection.insertOne(todoItem) { result in
                    switch result {
                    case .failure(let e):
                        print("error inserting item, \(e.localizedDescription)")
                        // an error occured, so remove the newTableViewControllernd reload the data again to refresh the ui
                        DispatchQueue.main.async {
                            //self.todoItems.removeLast()
                            //self.tableView.reloadData()
                        }
                    case .success:
                        // no action necessary
                        print("successfully inserted a Pool.")
                    }
                }
            }
        }))
        self.present(alertController, animated: true)
    }
    
    // Refresh the Collection of Pools
    func refreshView(){
        if stitch.auth.isLoggedIn {
            itemsCollection?.find(["all participants": [ "$eq": self.userId!] as Document]).toArray ({ result in
                switch result {
                case .success(let todos):
                    self.data = todos
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.numPools = self.data.count
                    }
                case .failure(let e):
                    print("User not logged in. \(e.localizedDescription))")
                    //fatalError(e.localizedDescription)
                }
            })
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dots.currentPage = Int((collectionView.contentOffset.x / collectionView.frame.width).rounded(.toNearestOrAwayFromZero))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshView()
        self.view.setNeedsDisplay()
    }
    
    //Get User ID
    var userId: String? {
        return stitch.auth.currentUser?.id
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        if stitch.auth.isLoggedIn {
            itemsCollection.find(["all participants": [ "$eq": self.userId!] as Document]).toArray { result in
                switch result {
                case .success(let todos):
                    self.data = todos
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt IndexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 1, height: collectionView.frame.height * 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        dots.numberOfPages = data.count
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = data[indexPath.row]
        let editController = EditPoolController()
        
        editController.task = String(item.task)
        editController.participants = item.participants
        editController.ownerId = String(item.ownerId)
        editController.createdDate = item.createdDate
        editController.fundingDate = item.fundingDate
        editController.amount = item.amount
        editController.amountFund = item.funded
        editController.amountUnfund = item.unfunded
        editController.paidParticipants = item.paidParticipants
        editController.unpaidParticipants = item.unpaidParticipants
        
        participants = item.participants
        allParticipants = item.allParticipants
        
        editController.headerTitle = String(item.task)
        present(UINavigationController(rootViewController: editController), animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomePoolsCellCollectionView
        
        let item = data[indexPath.row]
        let progressVal = Double(item.paidParticipants.count) / Double(item.participants)
        
        cell.name.text = item.task
        cell.setProgress(duration: 1.0, value: Float(progressVal))
        cell.durationVal = 1.0
        cell.endValue = progressVal
        
        cell.trackColor = .gray
        cell.progressColor = progressColor[indexPath.row % 7]
    
        let partStr = String(item.participants) + " Participants ("
        let paidStr = String(item.paidParticipants.count) + " paid)"
        cell.participants.text = partStr + paidStr
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        if (item.fundingDate > currentTime) {
            let fundDate = "Funds to be released on " + dateFormatter.string(from: item.fundingDate)
            cell.fundingDate.text = fundDate
        }else{
            let fundDate = "Funds Pending Release by Owner"
           cell.fundingDate.text = fundDate
        }
        
        //dots.currentPage = indexPath.row
        return cell
    }

    
    @objc func newUserInfo(){
        let newFalseAlertController = UIAlertController(title: "Updating Info Failed", message: nil, preferredStyle: .alert)
        newFalseAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let alertController = UIAlertController(title: "Enter First Name", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
                    if let firstName = alertController.textFields?[0].text{
                        if firstName != "" {
                            if stitch.auth.isLoggedIn {
                                let query : Document = ["_id": self.userId!];
                                let newFirstName : Document = ["firstName": firstName];
                    
                            let options = RemoteUpdateOptions(upsert: true);
                                
                                usersCollection?.updateOne(filter: query, update: newFirstName, options: options) {result in
                                    switch result {
                                    case .success(let result):
                                            print(result)
                                            DispatchQueue.main.async {
                                            }
                                    case .failure(let error):
                                        print("Failed to update: \(error)");
                                    }
                                }
                            } else {
                                self.present(newFalseAlertController, animated: true)
                            }
                        }
                    }
        }))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleMenuToggle() {
        delegate?.handleMenuToggle(forMenuOption: nil)
    }
    
    @objc func refreshButton() {
        refreshView()
    }
    
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.barStyle = .black
        
        navigationItem.title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_menu_white_3x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenuToggle))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action:        #selector(refreshButton))
        
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }

}
