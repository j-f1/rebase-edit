//
//  LabelCommandCreator.swift
//  RebaseEdit
//
//  Created by Jed Fox on 8/1/21.
//

import SwiftUI

struct LabelCommandCreator<Picker: View>: View {
    let picker: Picker
    let onSelect: (String) -> Void

    @State private var label = ""

    var body: some View {
        VStack {
            HStack {
                picker
                TextField("Label", text: $label)
            }
            SelectButton {
                onSelect(label)
            }.disabled(label.isEmpty)
        }
    }
}

struct LabelCommandCreator_Previews: PreviewProvider {
    static var previews: some View {
        LabelCommandCreator(picker: EmptyView(), onSelect: { _ in })
    }
}
