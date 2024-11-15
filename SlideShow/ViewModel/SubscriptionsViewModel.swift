//
//  SubscriptionsViewModel.swift
//  SlideShow
//
//  Created by Oliver Moscow on 7/14/24.
//

import Foundation
import StoreKit


class SubscriptionsViewModel: ObservableObject {
    @Published var isSubscribed = false
    private var productID = "com.grassapper.slideshowmagic.pro.1weekly"
    
    init() {
        Task {
            await refreshPurchasedProducts()
        }
    }
    
    func refreshPurchasedProducts() async {
        // Iterate through the user's purchased products.
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                if transaction.productID == productID {
                    await MainActor.run {
                        self.isSubscribed = true
                    }
                     break
                }
            case .unverified(_, let verificationError):
                print("Unverified transaction: \(verificationError)")
            }
        }
    }
}
