//
//  DesignableView.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/27/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

import UIKit
import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

@IBDesignable
class DesignableView: UIView {
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet{
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet{
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat = 0 {
        didSet{
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable var shadowOffsetY: CGFloat = 0 {
        didSet{
            layer.shadowOffset.height = shadowOffsetY
        }
    }
}
