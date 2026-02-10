//
//  ShoppingListViewState.swift
//  FoodWise
//
//  Created by Illia Melnyk on 22.12.2025.
//
import Foundation

struct ShoppingListViewState {
    var shoppingLists: [ShoppingList] = []
    var currentItems: [ShoppingItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
}
