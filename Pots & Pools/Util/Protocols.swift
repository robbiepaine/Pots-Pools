//
//  Protocols.swift
//  Pots & Pools
//
//  Created by Robbie Paine on 8/26/19.
//  Copyright © 2019 Robbie Paine. All rights reserved.
//

protocol HomeControllerDelegate {
    func handleMenuToggle(forMenuOption: MenuOption?)
}

protocol HomePoolsControllerDelegate {
    func handleMenuToggle(forMenuOption: MenuOption?)
}

protocol historyTableControllerDelegate {
    func handleMenuToggle(forMenuOption: MenuOption?)
}
