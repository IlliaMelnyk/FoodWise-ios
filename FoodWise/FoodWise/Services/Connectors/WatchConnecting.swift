//
//  WatchConnecting.swift
//  CityGuide
//
//  Created by David Prochazka on 02.10.2025.
//

protocol WatchConnecting {
    func sendKitchenData(items: [KitchenItem])
    func sendShoppingData(lists: [ShoppingList], items: [ShoppingItem])
}

