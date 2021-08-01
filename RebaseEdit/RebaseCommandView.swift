//
//  RebaseCommandView.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI

extension Binding where Value == RebaseCommand {
    var sha: Binding<String>? {
        switch wrappedValue {
        case let .pick(sha):
            return Binding<String> { sha } set: { wrappedValue = .pick(sha: $0) }
        case let .reword(sha):
            return Binding<String> { sha } set: { wrappedValue = .reword(sha: $0) }
        case let .edit(sha):
            return Binding<String> { sha } set: { wrappedValue = .edit(sha: $0) }
        case let .squash(sha):
            return Binding<String> { sha } set: { wrappedValue = .squash(sha: $0) }
        case let .fixup(sha, options):
            return Binding<String> { sha } set: { wrappedValue = .fixup(sha: $0, options) }
        case .drop(let sha):
            return Binding<String> { sha } set: { wrappedValue = .drop(sha: $0) }
        default:
            return nil
//            fatalError("Attempted to read sha from binding containing `\(wrappedValue.rawValue)`")
        }
    }
}

extension Binding {
    init(_ value: Value, set: @escaping (Value) -> ()) {
        self.init(get: { value }, set: set)
    }
}

struct RebaseState {
    var fixupOptions = RebaseCommand.FixupMessageOptions.discard
    var message: String?
}

struct RebaseCommandView: View {
    @Binding var command: RebaseCommand

    @State var state = RebaseState()

    func makeBasicView(_ type: BasicRebaseCommandType, _ sha: String) -> BasicRebaseCommandView {
        BasicRebaseCommandView(
            type: Binding(type, set: { command = $0.toCommand(sha: sha, options: state.fixupOptions) }),
            sha: $command.sha!,
            state: $state
        )
    }

    var body: some View {
        HStack {
            switch command {
            case let .pick(sha):
                makeBasicView(.pick, sha)
            case let .reword(sha):
                makeBasicView(.reword, sha)
            case let .edit(sha):
                makeBasicView(.edit, sha)
            case let .squash(sha):
                makeBasicView(.squash, sha)
            case let .fixup(sha, _):
                makeBasicView(.fixup, sha)
            case .exec(let command):
                Text("Exec")
                    .frame(width: 65, alignment: .trailing)
                Text(command)
                    .font(.system(.body, design: .monospaced))
                Button { print("edit") } label: {
                    Image(systemName: "pencil")
                        .imageScale(.small)
                        .font(.body.weight(.black))
                }.buttonStyle(.borderless).hidden()
            case .break:
                Text("Break")
                    .frame(width: 65, alignment: .trailing)
                Color.secondary.frame(height: 1)
            case .drop(let sha):
                makeBasicView(.drop, sha)
            case .label(let label):
                Text("Label")
                    .frame(width: 65, alignment: .trailing)
                Text(label)
            case .reset(let label):
                Text("Reset")
                    .frame(width: 65, alignment: .trailing)
                Text(label)
            case .merge(let originalCommit, let label, let oneline):
                Text("Merge")
                Text("🐙")
            }
        }
    }
}

struct RebaseCommandView_Previews: PreviewProvider {
    static var previews: some View {
        RebaseCommandView(command: .constant(.pick(sha: "deadbeef")))
    }
}
