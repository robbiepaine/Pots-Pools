//
//  HomePoolsCellCollectionView.swift
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

class HomePoolsCellCollectionView: UICollectionViewCell {
    
    let name = UILabel()
    let fundingDate = UILabel()
    let participants = UILabel()
    let progressView = UIView()
    let progressLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var progress: Double = 0
    var startValue: Double = 0
    var endValue: Double = 100
    var animationStartDate = Date()
    var durationVal: Double = 2
    var bColor: UIColor = .white
    var bImage = UIImageView()
    
    let diamInt = CGFloat(240)
    let radiusInt = CGFloat(120)
    let centeringInt = CGFloat(25)
    //let radiusInt = UIScreen.main.bounds.height/7
    
    let countingLabel: UILabel = {
        let label = UILabel()
        label.text = "%\nFunded"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .black
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        createCircularPath()
    }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        createCircularPath()
        
    
        progressView.backgroundColor = bColor
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        
        bImage.translatesAutoresizingMaskIntoConstraints = false
        //bImage.image = UIImage(named: "unlock")
        
        name.backgroundColor = .blue
        name.layer.masksToBounds = true
        name.layer.cornerRadius = 25
        name.font = .boldSystemFont(ofSize: 20)
        name.textColor = .white
        //name.text = "Pool Init"
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        
        addSubview(name)
        addSubview(fundingDate)
//        fundingDate.backgroundColor = .white
//        fundingDate.layer.masksToBounds = true
//        fundingDate.layer.cornerRadius = 25
        fundingDate.font = .boldSystemFont(ofSize: 15)
        fundingDate.textColor = .white
        fundingDate.text = "Funds to be released on ..."
        
        fundingDate.translatesAutoresizingMaskIntoConstraints = false
        fundingDate.textAlignment = .center
        
        addSubview(participants)
//        participants.backgroundColor = .white
//        participants.layer.masksToBounds = true
//        participants.layer.cornerRadius = 25
        participants.font = .boldSystemFont(ofSize: 15)
        participants.textColor = .white
        participants.text = "... Participants"

        participants.translatesAutoresizingMaskIntoConstraints = false
        participants.textAlignment = .center
        addSubview(bImage)
        addSubview(countingLabel)
        countingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //addSubview(bImage)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink.add(to: .main, forMode: .default)
        
        let constraints =
            [
            progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor,constant: -radiusInt),
            progressView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -diamInt),
                
            name.heightAnchor.constraint(equalToConstant: 50),
            name.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            name.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: radiusInt),
            name.widthAnchor.constraint(equalToConstant: 250),
            
            fundingDate.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            fundingDate.centerYAnchor.constraint(equalTo: name.centerYAnchor, constant: 45),

            participants.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            participants.centerYAnchor.constraint(equalTo: fundingDate.centerYAnchor, constant: 30),

            countingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            countingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -radiusInt+centeringInt),
                
            bImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bImage.centerYAnchor.constraint(equalTo: self.centerYAnchor,constant: -centeringInt),
            ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func handleUpdate(){
        let now = Date()
        let elapsedTime = now.timeIntervalSince(animationStartDate)
        
        
        if elapsedTime > durationVal {
            self.countingLabel.text = String(format:"%.1f", (endValue * 100)) + "%\nFunded"
        }else {
        let percentage = elapsedTime / durationVal
        let value = percentage * (endValue - startValue)
            self.countingLabel.text = String(format:"%.1f", value * 100) + "%\nFunded"
    }
    
    }
    
    
    var progressColor = UIColor.blue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    
    fileprivate func createCircularPath(){
    
        let circularPath = UIBezierPath(arcCenter: progressView.center.applying(__CGAffineTransformMake(0, 0, 0, 0, radiusInt, (210-centeringInt))), radius: radiusInt , startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)

        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 10
        //trackLayer.lineWidth = self.frame.size.width/50
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeEnd = 1
        
        progressView.layer.addSublayer(trackLayer)
        
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.lineCap = .round
        setProgress(duration: durationVal, value: 1)
        progressView.layer.addSublayer(progressLayer)

    }

    func setProgress(duration: TimeInterval, value: Float) {
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.duration = duration
        basicAnimation.fromValue = 0
        basicAnimation.toValue = value
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        progressLayer.add(basicAnimation, forKey: "animate")
        
        if value == 1{
            bImage.image = UIImage(named: "lock")
        }else{
            bImage.image = UIImage(named: "unlock")
            //bImage.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -40).isActive = true
        }
        bImage.image = bImage.image?.withRenderingMode(.alwaysTemplate)
        bImage.tintColor = .blue

    }
}

