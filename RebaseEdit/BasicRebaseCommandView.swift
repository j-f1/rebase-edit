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
}

struct BasicRebaseCommandView: View {
    @Binding var type: BasicRebaseCommandType
    @Binding var sha: String
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
            Text(sha).font(.system(.body, design: .monospaced))
            Spacer()
        }
    }
}

struct BasicRebaseCommandView_Previews: PreviewProvider {
    static var previews: some View {
        BasicRebaseCommandView(type: .constant(.pick), sha: .constant("abcdef"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
