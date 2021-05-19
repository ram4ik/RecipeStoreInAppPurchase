//
//  Recipe.swift
//  RecipeStoreInAppPurchase
//
//  Created by ramil on 19.05.2021.
//

import Foundation
import StoreKit

struct Recipe: Hashable {
    let id: String
    let title: String
    let description: String
    var isLocked: Bool
    var price: String?
    var locale: Locale
    var imageName: String
    
    lazy var formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.locale = locale
        return nf
    }()
    
    init(product: SKProduct, isLocked: Bool = true) {
        self.id = product.productIdentifier
        self.title = product.localizedTitle
        self.description = product.localizedDescription
        self.isLocked = isLocked
        self.locale = product.priceLocale
        self.imageName = product.productIdentifier
        
        if isLocked {
            self.price = formatter.string(from: product.price)
        }
    }
}
