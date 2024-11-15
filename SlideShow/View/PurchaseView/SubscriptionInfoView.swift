//
//  RestoreView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/21/24.
//

import SwiftUI

struct SubscriptionInfoView: View {
    @Binding var showInfoSheet: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    
                    Text("Your Subscription info")
                        .foregroundStyle(.white)
                        .font(.title2)
                    
                    Spacer()
                    
                    Button {
                        showInfoSheet = false
                    } label: {
                        Image(systemName: "x.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                
                Rectangle()
                    .fill(.accent)
                    .frame(height: 1.5)
                    .edgesIgnoringSafeArea(.horizontal)
                
                Spacer()
                
                Text("Payment will be charged to iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period \n\nAccount will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal. \n\nSubscriptions may be managed by the user and auto-renewal may be turnedoff by going to the user's Account Settings after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable. Please view or [Terms and Condition](https://www.grassapper.com/terms-and-conditions) and [Privacy Policy](https://www.grassapper.com/application-privacy-policy) for more details.")
                    .foregroundStyle(.white)
                    .font(.callout)
                    .padding()
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
