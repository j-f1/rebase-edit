//
//  SelectButton.swift
//  RebaseEdit
//
//  Created by Jed Fox on 8/1/21.
//

import SwiftUI

struct SelectButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer(minLength: 0)
                Text("Add to rebase")
                    .truncationMode(.middle)
                Spacer(minLength: 0)
            }
            .frame(width: 288)
        }
        .keyboardShortcut(.defaultAction)
        .controlSize(.large)
    }
}

struct SelectButton_Previews: PreviewProvider {
    static var previews: some View {
        SelectButton { }
    }
}
