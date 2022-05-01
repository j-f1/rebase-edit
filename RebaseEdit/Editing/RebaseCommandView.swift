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

struct RebaseCommandRow<Label: View, Content: View>: View {
    let label: Label
    let content: Content

    var body: some View {
        HStack {
            label.frame(width: 65, alignment: .trailing)
            content
        }
    }
}

extension RebaseCommandRow where Label == Text {
    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = Text(label).fontWeight(.medium)
        self.content = content()
    }
}

struct RebaseCommandView: View {
    let isSelected: Bool
    @Binding var command: RebaseCommand

    @State var state = RebaseState()

    func makeBasicView(_ type: BasicRebaseCommandType, _ sha: String) -> BasicRebaseCommandView {
        BasicRebaseCommandView(
            isSelected: isSelected,
            type: Binding(type, set: { command = $0.toCommand(sha: sha, options: state.fixupOptions) }),
            sha: $command.sha!,
            state: $state
        )
    }

    var body: some View {
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
            RebaseCommandRow("Exec") {
                Text(command)
                    .font(.system(.body, design: .monospaced))
                EditButton(
                    initialText: command,
                    font: .system(.body, design: .monospaced),
                    onSave: { self.command = .exec(command: $0) }
                )
            }
        case .break:
            RebaseCommandRow("Break") {
                Color.secondary.frame(height: 1)
            }
        case .drop(let sha):
            makeBasicView(.drop, sha)
        case .label(let label):
            RebaseCommandRow("Label") {
                Text(label)
                EditButton(
                    initialText: label,
                    font: .body,
                    onSave: { self.command = .label(label: $0) }
                )
            }
        case .reset(let label):
            RebaseCommandRow("Reset") {
                Text(label)
                EditButton(initialText: label, onSave: { self.command = .reset(label: $0) })
            }
        case .merge:
            RebaseCommandRow("Merge") {
                Text("🐙")
            }
        }
    }
}

struct RebaseCommandView_Previews: PreviewProvider {
    static var previews: some View {
        RebaseCommandView(isSelected: false, command: .constant(.pick(sha: "deadbeef")))
    }
}
