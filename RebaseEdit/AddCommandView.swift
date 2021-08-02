//
//  AddCommandView.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI
import SwiftGit2
import Introspect

struct AddCommandView: View {
    let hashLength: Int
    let onSelect: (RebaseCommand) -> ()

    @State private var type = RebaseCommandType.pick
    @State private var fixupOptions = RebaseCommand.FixupMessageOptions.discard

    var body: some View {
        VStack {
            let picker = HStack {
                Picker(selection: $type, label: EmptyView()) {
                    ForEach(RebaseCommandType.allCases) { type in
                        if type != .merge {
                            Text(type.rawValue.capitalized)
                                .tag(type)
                        }
                    }
                }.fixedSize()
                if type == .fixup {
                    Menu {
                        Picker(selection: $fixupOptions, label: EmptyView()) {
                            Text("Discard Message").tag(RebaseCommand.FixupMessageOptions.discard)
                            Text("Keep Message").tag(RebaseCommand.FixupMessageOptions.use)
                            Text("Keep Message & Edit").tag(RebaseCommand.FixupMessageOptions.useAndEdit)
                        }.pickerStyle(.inline)
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .frame(width: 25)
                    .controlSize(.small)
                    .padding(.horizontal, -3)
                }
            }

            switch type {
            case .pick, .reword, .edit, .squash, .fixup, .drop:
                CommitSearchView(picker: picker) { commit in
                    type.command(sha: String(commit.oid.description.prefix(hashLength)), fixup: fixupOptions)
                        .map(onSelect)
                }
            case .exec:
                ExecCommandCreator(picker: picker) { command in
                    onSelect(.exec(command: command))
                }
            case .break:
                HStack {
                    picker
                    Spacer()
                }
                SelectButton {
                    onSelect(.break)
                }
            case .label:
                LabelCommandCreator(picker: picker) { label in
                    onSelect(.label(label: label))
                }
            case .reset:
                LabelCommandCreator(picker: picker) { label in
                    onSelect(.reset(label: label))
                }
            case .merge:
                picker
            }
        }
        .frame(width: 300)
        .padding(10)
        .textFieldStyle(.roundedBorder)
    }
}

struct AddCommandView_Previews: PreviewProvider {
    static var previews: some View {
        AddCommandView(hashLength: 7, onSelect: { _ in })
    }
}
