//
//  RecipeStoreInAppPurchaseApp.swift
//  RecipeStoreInAppPurchase
//
//  Created by ramil on 19.05.2021.
//

import SwiftUI

@main
struct RecipeStoreInAppPurchaseApp: App {
    @StateObject private var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
