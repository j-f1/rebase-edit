//
//  EditButton.swift
//  RebaseEdit
//
//  Created by Jed Fox on 8/2/21.
//

import SwiftUI

struct EditButton: View {
    let initialText: String
    var font = Font.body
    let onSave: (String) -> Void

    @State private var isEditing = false
    @State private var editingText = ""

    var body: some View {
        Button {
            editingText = initialText
            isEditing = true
        } label: {
            Image(systemName: "pencil")
                .imageScale(.small)
                .font(.body.weight(.black))
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $isEditing) {
            HStack {
                TextField("enter command", text: $editingText)
                    .font(font)
                    .frame(width: 300)
                    .textFieldStyle(.roundedBorder)
                    .introspectTextField { $0.becomeFirstResponder() }
                Button("Save") {
                    onSave(editingText)
                    isEditing = false
                }.keyboardShortcut(.defaultAction)
            }.padding(5)
        }
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        EditButton(initialText: "", onSave: { _ in })
    }
}
