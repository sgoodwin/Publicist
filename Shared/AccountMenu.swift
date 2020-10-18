//
//  AccountMenu.swift
//  Publicist
//
//  Created by Samuel Goodwin on 9/21/20.
//

import SwiftUI
import BlogEngine
import CoreData

struct AccountMenu: View {
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @FetchRequest(fetchRequest: Account.canonicalOrder()) var fetchedResults: FetchedResults
    
    @Binding var selectedAccount: Account?
    
    var body: some View {
        Menu(selectedAccount?.name ?? "Select Account") {
            ForEach(_fetchedResults.wrappedValue, id: \.self) { account in
                Button(account == selectedAccount ? "✓ " + account.name! : account.name!) {
                    selectedAccount = account
                }
            }
        }
        .menuStyle(AccountMenyStyle())
    }
}

struct AccountMenu_Previews: PreviewProvider {
    static var previews: some View {
        Menu("menu") {
            Button("Sup") {
                print("yay")
            }
        }
        .menuStyle(AccountMenyStyle())
    }
}

struct AccountMenyStyle: MenuStyle {
    #if os(macOS)

    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
    }

    #else

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Menu(configuration)
            Image(systemName: "chevron.down")
                .accentColor(.white)
        }
        .foregroundColor(.white)
        .font(.headline)
        .padding(
            EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.accentColor)
        )
    }
    
    #endif
}
