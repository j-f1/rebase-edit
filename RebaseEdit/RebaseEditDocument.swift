//
//  RebaseEditDocument.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var gitRebaseTodo: UTType {
        UTType(importedAs: "com.jedfox.git-rebase-todo")
    }
}

struct RebaseEditDocument: FileDocument {
    var commands: [RebaseCommand]

    init(text: String = "") {
        self.commands = RebaseCommand.parse(text)
    }

    static var readableContentTypes: [UTType] { [.gitRebaseTodo] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.commands = RebaseCommand.parse(string)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = commands.map(\.rawValue).joined(separator: "\n").data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
