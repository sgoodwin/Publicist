//
//  ProgressWithStatus.swift
//  Publicist
//
//  Created by Samuel Goodwin on 8/3/20.
//

import SwiftUI

extension Progress: ObservableObject {}

struct ProgressWithStatus: View {
    let progress: Progress
    
    var body: some View {
        ProgressView(progress)
            .progressViewStyle(LinearProgressViewStyle())
            .frame(maxWidth: 120)
            .padding()
    }
}

struct ProgressWithStatus_Previews: PreviewProvider {
    static var progress: Progress {
        let p = Progress(totalUnitCount: 1)
        p.localizedDescription = "Doing stuff..."
        p.completedUnitCount = 0
        return p
    }
    
    static var previews: some View {
        ProgressWithStatus(progress: progress)
    }
}
