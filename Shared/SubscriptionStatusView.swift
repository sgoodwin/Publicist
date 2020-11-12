//
//  SubscriptionStatusView.swift
//  Publicist
//
//  Created by Samuel Goodwin on 11/9/20.
//

import SwiftUI

struct Banner: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Subscribe to unlock all features")
                .background(
                    Color(.sRGB, red: 0.290, green: 0.161, blue: 0.765, opacity: 1.0)
                        .frame(height: 40)
                        .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: 0))
                )
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                
            Image("Unlock")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
        }
        .padding(0)
    }
}

struct SubscriptionStatusView: View {
    @EnvironmentObject var controller: SubscriptionController
    
    var body: some View {
        if controller.subscriptionValid {
            EmptyView()
        } else {
            HStack {
                Button(action: subscribe, label: {
                    Banner()
                })
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                
                Button("Already a subscriber?\nRestore Subscription") {
                    controller.refresh()
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8))
                .lineLimit(2)
            }
        }
    }
    
    func subscribe() {
        controller.subscribe()
    }
}

struct SubscriptionStatusView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SubscriptionStatusView()
        }
    }
}
