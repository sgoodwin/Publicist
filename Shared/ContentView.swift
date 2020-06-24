//
//  ContentView.swift
//  Shared
//
//  Created by Samuel Goodwin on 6/24/20.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSettings: Bool = false
    @State var statusMessage = ""
    
    var body: some View {
        NavigationView {
            SearchablePostsList()
            .sheet(isPresented: $showingSettings) {
                Settings()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: fakeRefreshing, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingSettings.toggle()
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
                ToolbarItem(placement: .status) {
                    HStack {
                        Text(statusMessage)
                        if !statusMessage.isEmpty {
                            ProgressView()
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension ContentView {
    func fakeRefreshing() {
        // Some nonsense to fake like work is happening
        withAnimation {
            statusMessage = "Fetching posts..."
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            withAnimation {
                statusMessage = ""
            }
        }
        // End nonsense
    }
}

struct SearchablePostsList: View {
    @State var searchText: String = ""
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText).padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            List(0..<3) {_ in
                PostCell()
                    .contextMenu {
                        Link("View Article", destination: URL(string: "https://google.com")!)
                        Button("Share") {
                            print("share!")
                        }
                        Button("Delete") {
                            print("Delete!")
                        }
                    }
            }
        }
    }
}

struct Settings: View {
    var body: some View {
        Text("This is settings! Mostly so you can add new accounts.").padding()
    }
}

struct Migrate: View {
    var body: some View {
        Text("Pick which account you wanna migrate from and to!").padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
