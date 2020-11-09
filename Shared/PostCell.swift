//
//  PostCell.swift
//  Publicist
//
//  Created by Samuel Goodwin on 6/24/20.
//

import SwiftUI
import BlogEngine

struct StatusLabel: View {
    let status: PostStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.subheadline)
            .padding(6)
            .foregroundColor(.accentColor)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor)
            )
    }
}

struct PostCell: View {
    let post: Post
    
    static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(verbatim: post.title ?? "Untitled")
                    .font(.headline)
                Text("\(post.publishedDate!, formatter: Self.dateFormat)")
                    .font(.subheadline)
                
                Spacer()
                
                VStack {
                if post.postStatus == .draft {
                    StatusLabel(status: post.postStatus)
                }
                if post.postStatus == .scheduled {
                    StatusLabel(status: post.postStatus)
                }
                }.background(Color.red)
            }
            Text(verbatim: post.excerpt ?? "-")
                .font(.body)
                .lineLimit(nil)
        }.padding()
    }
}

struct PostCell_Previews: PreviewProvider {
    static var post: Post {
        let post = Post(context: container.viewContext)
        post.title = "This is a blog post"
        post.publishedDate = Date()
        post.excerpt = "This is the excerpt of the text. It shouldn't be suuuper long."
        
        return post
    }
    
    static var previews: some View {
        PostCell(post: post)
    }
}
