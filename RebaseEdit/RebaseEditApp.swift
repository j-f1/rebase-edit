//
//  RebaseEditApp.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI

@main
struct RebaseEditApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: RebaseEditDocument(text: sample)) { file in
            ContentView(document: file.$document, url: file.fileURL)
                .frame(maxWidth: 500)
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}
