//
//  AddAccountForm.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI
import BlogEngine
import CoreData

extension String: Identifiable {
    public var id: String {
        return self
    }
}

struct AddAccountForm: View {
    let blogEngine: BlogEngine
    @State var formObject: AccountEntryValidator
    @Binding var showingSheet: Bool
    @State var error: String?
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        VStack {
            TabView(selection: $formObject.type) {
                WordpressForm(formObject: $formObject)
                    .tabItem { Text("Wordpress") }
                    .tag(SupportedBlogs.wordpress)
                GhostForm(formObject: $formObject)
                    .tabItem { Text("Ghost") }
                    .tag(SupportedBlogs.ghost)
                GhostV2Form(formObject: $formObject)
                    .tabItem { Text("Ghost (2.16+)") }
                    .tag(SupportedBlogs.ghostV2)
            }
            .padding()
            HStack {
                Button("Cancel") {
                    showingSheet.toggle()
                }
                .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Login") {
                    login()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!formObject.valid)
                .alert(item: $error) { (anError) -> Alert in
                    Alert(title: Text(anError))
                }
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 500)
    }
    
    func login() {
        let root = formObject.host
        let username = formObject.username
        let password = formObject.password
        let type = formObject.type
        let secret = formObject.clientSecret
        let apiKey = formObject.apiKey
        let clientID = formObject.clientID
        
        blogEngine.checkAccountInfo(context: managedObjectContext, root: root, username: username, password: password, clientID: clientID, clientSecret: secret, apiKey: apiKey, type: type) { (error) in
            if let _ = error {
                self.error = "Failed to verify account info. Please double check."
            } else {
                showingSheet = false
            }
        }
    }
}

struct WordpressForm: View {
    @Binding var formObject: AccountEntryValidator
    
    var body: some View {
        Form(content: {
            TextField("URL", text: $formObject.host)
            TextField("Username or Email", text: $formObject.username)
            TextField("Password", text: $formObject.password)
                .textContentType(.password)
            Section {
                Text("If you are using wordpress.com as your host, you might need your email address rather than your username to log in.")
            }
        })
        .padding()
    }
}

struct GhostForm: View {
    @Binding var formObject: AccountEntryValidator
    
    var body: some View {
        Form(content: {
            TextField("URL", text: $formObject.host)
            TextField("Client ID", text: $formObject.clientID)
            TextField("Client Secret", text: $formObject.clientSecret)
                .textContentType(.password)
            Section {
                Text("Self-hosted Ghost blogs using versions earlier than 2.16.1 will need to use this option.")
            }
        })
        .padding()
    }
}

struct GhostV2Form: View {
    @Binding var formObject: AccountEntryValidator
    
    var body: some View {
        Form(content: {
            TextField("URL", text: $formObject.host)
            TextField("Admin API Key", text: $formObject.apiKey)
            Section {
                Text("Self-hosted Ghost blogs using versions earlier than 2.16.1 will need to use this option.")
            }
        })
        .padding()
    }
}

struct AddAccountForm_Previews: PreviewProvider {
    static var blogEngine: BlogEngine {
        return BlogEngine(context: container.viewContext)
    }
    
    static var previews: some View {
        AddAccountForm(blogEngine: blogEngine, formObject: AccountEntryValidator(), showingSheet: .constant(true))
    }
}
