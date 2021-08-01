//
//  RebaseEditApp.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI

@propertyWrapper
class Box<T>: ObservableObject {
    var wrappedValue: T? {
        didSet {
            if (wrappedValue == nil) != (oldValue == nil) {
                objectWillChange.send()
            }
        }
    }

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

@main
struct RebaseEditApp: App {
    @Box var onDelete: (() -> Void)?
    var body: some Scene {
        DocumentGroup(newDocument: RebaseEditDocument(text: sample)) { file in
            ContentView(document: file.$document, url: file.fileURL)
                .frame(maxWidth: 500)
                .backgroundPreferenceValue(OnDeletePrefKey.self) { onDelete in
                    { () -> EquatableView<Color> in
                        if let onDelete = onDelete {
                            self.onDelete = onDelete
                        }
                        return EquatableView(content: Color.clear)
                    }()
                }
        }.commands {
            CommandGroup(after: .pasteboard) {
                Button("Delete", action: { self._onDelete.wrappedValue?() })
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(onDelete == nil)
            }
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}


struct OnDeletePrefKey: PreferenceKey {
    typealias Value = (() -> Void)?

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
