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
    let publishedDate: Date?
    
    let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
    
    var body: some View {
        if status == .draft {
            VStack {
                Image(systemName: "doc.badge.ellipsis")
                    .imageScale(.large)
                Text("Draft")
            }
            .padding()
        } else if status == .scheduled {
            VStack {
                Image(systemName: "calendar.badge.clock")
                    .imageScale(.large)
                Text(publishedDate!, formatter: dateFormat)
            }
            .padding()
        } else {
            Text(publishedDate!, formatter: dateFormat)
        }
    }
}

protocol PostLike {
    var title: String? { get }
    var postStatus: PostStatus { get }
    var excerpt: String? { get }
    var publishedDate: Date? { get }
}

extension Post: PostLike {}

struct PostCell: View {
    let post: PostLike
    
    let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(verbatim: post.title ?? "Untitled")
                    .font(.headline)
                Text(verbatim: post.excerpt ?? "-")
                    .font(.body)
                    .lineLimit(nil)
            }
            
            Spacer()
            
            StatusLabel(
                status: post.postStatus,
                publishedDate: post.publishedDate
            )
        }
         .padding()
    }
}

struct PostStruct: PostLike {
    var title: String? = "This is the title"
    
    var postStatus: PostStatus
    
    var excerpt: String? = "Thisi s an exerpt. It's the first paragraph in the thing."
    
    var publishedDate: Date? = Date()
}

struct PostCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PostCell(post: PostStruct(postStatus: .draft))
            PostCell(post: PostStruct(postStatus: .scheduled))
            PostCell(post: PostStruct(postStatus: .published))
        }
    }
}
