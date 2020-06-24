//
//  PostCell.swift
//  Publicist
//
//  Created by Samuel Goodwin on 6/24/20.
//

import SwiftUI

struct PostCell: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Some Important Blog Post")
                .font(.headline)
            Text("January 13, 2019")
                .font(.subheadline)
        }
    }
}

struct PostCell_Previews: PreviewProvider {
    static var previews: some View {
        PostCell()
    }
}
