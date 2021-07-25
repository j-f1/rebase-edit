//
//  RebaseCommandView.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI

extension Binding where Value == RebaseCommand {
    var sha: Binding<String> {
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
            fatalError("Attempted to read sha from binding containing `\(wrappedValue.rawValue)`")
        }
    }
}

extension Binding {
    init(_ value: Value, set: @escaping (Value) -> ()) {
        self.init(get: { value }, set: set)
    }
}

struct RebaseCommandView: View {
    @Binding var command: RebaseCommand

    @State var fixupOptions = RebaseCommand.FixupMessageOptions.discard

    func makeSetter(sha: String) -> (BasicRebaseCommandType) -> () {
        { command = $0.toCommand(sha: sha, options: fixupOptions) }
    }

    var body: some View {
        HStack {
            switch command {
            case let .pick(sha):
                BasicRebaseCommandView(
                    type: Binding(.pick, set: makeSetter(sha: sha)),
                    sha: $command.sha
                )
            case let .reword(sha):
                BasicRebaseCommandView(
                    type: Binding(.reword, set: makeSetter(sha: sha)),
                    sha: $command.sha
                )
            case let .edit(sha):
                BasicRebaseCommandView(
                    type: Binding(.edit, set: makeSetter(sha: sha)),
                    sha: $command.sha
                )
            case let .squash(sha):
                BasicRebaseCommandView(
                    type: Binding(.squash, set: makeSetter(sha: sha)),
                    sha: $command.sha
                )
            case let .fixup(sha, _):
                BasicRebaseCommandView(
                    type: Binding(.fixup, set: makeSetter(sha: sha)),
                    sha: $command.sha
                )
            case .exec(let command):
                Text("Exec")
                Text(command).font(.system(.body, design: .monospaced))
            case .break:
                Text("Break")
            case .drop(let sha):
                BasicRebaseCommandView(
                    type: Binding(.drop, set: makeSetter(sha: sha)),
                    sha: $command.sha
                )
            case .label(let label):
                Text("Label")
                Text(label)
            case .reset(let label):
                Text("Label")
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