//
//  MenuOption.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/26/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

import UIKit

enum MenuOption: Int, CustomStringConvertible {
    case Balance
    case Blank
    case Profile
    case Inbox
    case History
    case Settings
    case Logout
    
    var description: String {
        switch self {
        case .Balance: return "Balance"
        case .Blank: return ""
        case .Profile: return "Profile"
        case .Inbox: return "Inbox"
        case .History: return "My Pools"
        case .Settings: return "Settings"
        case .Logout: return "Logout"
        }
    }
    
    var image: UIImage {
        switch self {
        case .Balance: return UIImage(named: "balance") ?? UIImage()
        case .Blank: return UIImage(named: "") ?? UIImage()
        case .Profile: return UIImage(named: "ic_person_outline_white_2x") ?? UIImage()
        case .Inbox: return UIImage(named: "ic_mail_outline_white_2x") ?? UIImage()
        case .History: return UIImage(named: "ic_menu_white_3x") ?? UIImage()
        case .Settings: return UIImage(named: "baseline_settings_white_24dp") ?? UIImage()
        case .Logout: return UIImage(named: "key") ?? UIImage()
        }
    }
    
}
