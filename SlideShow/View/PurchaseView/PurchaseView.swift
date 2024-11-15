//
//  PurchaseView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/21/24.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Environment(\.purchase) private var purchase: PurchaseAction
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionsViewModel: SubscriptionsViewModel
    
    var isSheet: Bool
    @State var showInfoSheet = false
    @State private var showSubscriptionAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("IAPBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height + 40)
                    .edgesIgnoringSafeArea(.all)
                
                if subscriptionsViewModel.isSubscribed {
                    VStack {
                        Spacer()
                        Text("Thanks for subscribing!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Enjoy Slideshow Pro")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 20) {
                        HStack {
                            if isSheet {
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        Text("Get access to Slideshow")
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 25)
                        
                        Text("Try 7 days for free")
                            .foregroundColor(.white)
                        
                        Button {
                            Task {
                                do {
                                    let product = try await Product.products(for: ["com.grassapper.slideshowmagic.pro.1weekly"])
                                    if let product = product.first {
                                        let purchaseResult = try await product.purchase()
                                        switch purchaseResult {
                                        case .success(let verificationResult):
                                            switch verificationResult {
                                            case .verified(let transaction):
                                                // Update the subscription status
                                                await subscriptionsViewModel.refreshPurchasedProducts()
                                                showSubscriptionAlert = true
                                            case .unverified:
                                                print("Transaction unverified")
                                            }
                                        case .userCancelled:
                                            print("User cancelled")
                                        case .pending:
                                            print("Purchase pending")
                                        @unknown default:
                                            print("Unknown purchase result")
                                        }
                                    }
                                } catch {
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            Text("Continue")
                                .font(.title2)
                                .frame(width: geometry.size.width * 0.75, height: 50)
                                .background(Color.accentColor)
                                .cornerRadius(25)
                                .bold()
                                .foregroundColor(.black)
                        }
                        
                        Text("7 days then $12.99 per week")
                            .foregroundColor(.white)
                        
                        Spacer()
                            .frame(height: 25)
                    }
                    .padding(30)
                }
            }
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !subscriptionsViewModel.isSubscribed {
                        Button {
                            
                        } label: {
                            Text("Already Purchased?")
                                .font(.system(size: 20))
                                .underline()
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInfoSheet = true
                    } label: {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .black]), startPoint: .top, endPoint: .bottom)
            )
            .sheet(isPresented: $showInfoSheet) {
                SubscriptionInfoView(showInfoSheet: $showInfoSheet)
                    .presentationDetents([.large])
            }
            .alert("Subscription Successful", isPresented: $showSubscriptionAlert) {
                Button("OK") {
                    if isSheet {
                        dismiss()
                    }
                }
            } message: {
                Text("You have successfully subscribed to Slideshow Pro!")
            }
        }
    }
}

