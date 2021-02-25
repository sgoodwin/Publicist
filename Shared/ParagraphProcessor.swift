//
//  ParagraphProcessor.swift
//  Publisher
//
//  Created by Samuel Goodwin on 12/18/18.
//  Copyright © 2018 Roundwall Software. All rights reserved.
//

import Foundation
import BlogEngine

struct ProcessedContent: Equatable {
    let contents: String
    let images: [ImageStruct]
}

class ParagraphProcessor {
    let blogEngine: BlogEngine
    
    init(engine: BlogEngine) {
        blogEngine = engine
    }
    
    func process(paragraphs: [NSDictionary], intoAccount account:Account, completion: @escaping (Result<ProcessedContent, UploadError>) -> ()) {
        let group = DispatchGroup()
        
        var paragraphs = paragraphs
        var error: UploadError?
        
        var images = [ImageStruct]()
        
        for (index, paragraph) in paragraphs.enumerated() {
            if let imageURL = paragraph["imageURL"] as? URL {
                group.enter()
                try! blogEngine.upload(imageURL: imageURL, toAccount: account.objectID) { (result) in
                    switch result {
                    case .success(let remoteURL):
                        paragraphs.insert(["text": "![](\(remoteURL))"], at: index)
                        if let data = try? Data(contentsOf: imageURL) {
                            images.append(ImageStruct(data: data, url: remoteURL))
                        }
                    case .failure(let uploadError):
                        error = uploadError
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let contents = paragraphs.compactMap({ (paragraph) -> String? in
                return paragraph["text"] as? String
            }).joined(separator: "\n\n")
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ProcessedContent(contents: contents, images: images)))
            }
        }
    }
}
