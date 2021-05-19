//
//  Store.swift
//  RecipeStoreInAppPurchase
//
//  Created by ramil on 19.05.2021.
//

import StoreKit

typealias FetchCompletionHandler = (([SKProduct]) -> Void)
typealias PurchaseCompletionHandler = ((SKPaymentTransaction?) -> Void)

class Store: NSObject, ObservableObject {
    
    @Published var allRecipe = [Recipe]()
    
    private let allProductIdentifiers = Set([
        "com.ri.RecipeStoreInAppPurchase.berryBlue",
        "com.ri.RecipeStoreInAppPurchase.lemon"
    ])
    
    private var completedPurchases = [String]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for index in self.allRecipe.indices {
                    self.allRecipe[index].isLocked = !self.completedPurchases.contains(self.allRecipe[index].id)
                }
            }
        }
    }
    
    private var productsRequest: SKProductsRequest?
    private var fetchedProducts = [SKProduct]()
    private var fetchCompletionHandler: FetchCompletionHandler?
    private var purchaseCompletionHandler: PurchaseCompletionHandler?
    
    override init() {
        super.init()
        
        startObservingPaymentQueue()
        
        fetchProducts { products in
            self.allRecipe = products.map { Recipe(product: $0) }
        }
    }
    
    private func startObservingPaymentQueue() {
        SKPaymentQueue.default().add(self)
    }
    
    private func fetchProducts(_ completion: @escaping FetchCompletionHandler) {
        guard self.productsRequest == nil else { return }
        
        fetchCompletionHandler = completion
        
        productsRequest = SKProductsRequest(productIdentifiers: allProductIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    private func buy(_ product: SKProduct, completion: @escaping PurchaseCompletionHandler) {
        purchaseCompletionHandler = completion
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    
}

extension Store {
    func product(for identifier: String) -> SKProduct? {
        return fetchedProducts.first(where: { $0.productIdentifier == identifier })
    }
    
    func purchaseProduct(_ product: SKProduct) {
        startObservingPaymentQueue()
        buy(product) { _ in }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension Store: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            var shouldFinishTransaction = false
            switch transaction.transactionState {
            case .purchased, .restored:
                completedPurchases.append(transaction.payment.productIdentifier)
                shouldFinishTransaction = true
            case .failed:
                shouldFinishTransaction = true
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
            
            if shouldFinishTransaction {
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.purchaseCompletionHandler?(transaction)
                    self.purchaseCompletionHandler = nil
                }
            }
        }
    }
    
    
}

extension Store: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let loadedProducts = response.products
        let invalidProducts = response.invalidProductIdentifiers
        
        guard !loadedProducts.isEmpty else {
            print("Could not load the products!")
            if !invalidProducts.isEmpty {
                print("Invalid products found: \(invalidProducts)")
            }
            productsRequest = nil
            return
        }
        
        fetchedProducts = loadedProducts
        
        DispatchQueue.main.async {
            self.fetchCompletionHandler?(loadedProducts)
            self.fetchCompletionHandler = nil
            self.productsRequest = nil
        }
    }
        
    
}
