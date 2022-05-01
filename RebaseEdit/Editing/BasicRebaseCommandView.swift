//
//  BasicRebaseCommandView.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI

enum BasicRebaseCommandType: String, CaseIterable {
    case pick = "Pick"
    case reword = "Reword"
    case edit = "Edit"
    case squash = "Squash"
    case fixup = "Fixup"
    case drop = "Drop"

    func toCommand(sha: String, options: RebaseCommand.FixupMessageOptions) -> RebaseCommand {
        switch self {
        case .pick: return .pick(sha: sha)
        case .reword: return .reword(sha: sha)
        case .edit: return .edit(sha: sha)
        case .squash: return .squash(sha: sha)
        case .fixup: return .fixup(sha: sha, options)
        case .drop: return .drop(sha: sha)
        }
    }

    var keyEquivalent: KeyEquivalent {
        switch self {
        case .pick: return "p"
        case .reword: return "r"
        case .edit: return "e"
        case .squash: return "s"
        case .fixup: return "f"
        case .drop: return "d"
        }
    }
}

struct BasicRebaseCommandView: View {
    let isSelected: Bool
    @Binding var type: BasicRebaseCommandType
    @Binding var sha: String
    @Binding var state: RebaseState

    var body: some View {
        HStack {
            Menu {
                Picker(selection: $type, label: EmptyView()) {
                    ForEach(BasicRebaseCommandType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Text(type.rawValue)
                    .font(.body.weight(.semibold))
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .fixedSize()
            .frame(width: 65, alignment: .trailing)
            CommitEditView(canEdit: type == .reword, sha: $sha, state: $state)
            Spacer()
            if isSelected {
                ZStack {
                    ForEach(BasicRebaseCommandType.allCases, id: \.self) { type in
                        if type != self.type {
                            Button { self.type = type } label: { EmptyView() }
                            .keyboardShortcut(type.keyEquivalent, modifiers: [])
                        }
                    }
                }.buttonStyle(.borderless)
            }
        }.overlay(isSelected ? Color.red : Color.clear)
    }
}

struct BasicRebaseCommandView_Previews: PreviewProvider {
    static var previews: some View {
        BasicRebaseCommandView(isSelected: false, type: .constant(.pick), sha: .constant("abcdef"), state: .constant(RebaseState()))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
