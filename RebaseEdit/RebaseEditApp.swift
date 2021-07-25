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
        DocumentGroup(newDocument: RebaseEditDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
