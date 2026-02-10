//
//  KitchenListViewState.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation
import Observation
import SwiftUI

struct KitchenListViewState {
    var products: [KitchenItem] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
}
