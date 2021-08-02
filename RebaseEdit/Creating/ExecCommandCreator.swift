//
//  ExecCommandCreator.swift
//  RebaseEdit
//
//  Created by Jed Fox on 8/1/21.
//

import SwiftUI

struct ExecCommandCreator<Picker: View>: View {
    let picker: Picker
    let onSelect: (String) -> Void

    @State private var command = ""

    var body: some View {
        VStack {
            HStack {
                picker
                TextField("enter command", text: $command)
                    .font(.system(.body, design: .monospaced))
            }
            SelectButton {
                onSelect(command)
            }.disabled(command.isEmpty)
        }
    }
}

struct ExecCommandCreator_Previews: PreviewProvider {
    static var previews: some View {
        ExecCommandCreator(picker: EmptyView(), onSelect: { _ in })
    }
}
