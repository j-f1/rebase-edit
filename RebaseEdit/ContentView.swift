//
//  ContentView.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI
import SwiftGit2

extension EnvironmentValues {
    private struct RepoKey: EnvironmentKey {
        static let defaultValue: Repository? = nil
    }
    var repo: Repository! {
        get { self[RepoKey.self] }
        set { self[RepoKey.self] = newValue }
    }
}

struct ContentView: View {
    init(document: Binding<RebaseEditDocument>, url: URL?) {
        self._document = document
         self._repo = .init(initialValue: try! Repository.at(Self.findRepo(url: url)).get())
    }
    @Binding var document: RebaseEditDocument

    @State private var repo: Repository
    @State private var selection: Set<RebaseCommand> = []

    @State private var showAddPopover = false

    @Environment(\.scenePhase) var scenePhase

    static func findRepo(url: URL?) -> URL {
        let rebaseDir = url!.deletingLastPathComponent()
        let gitDir = rebaseDir.deletingLastPathComponent().path
        return URL(fileURLWithPath: String(gitDir), isDirectory: false)
    }

    private func onDelete() {
        document.commands.removeAll(where: selection.contains)
        selection = []
    }

    var hashLength: Int {
        let lengths: [Int] = document.commands.map(Binding.constant).compactMap(\.sha?.wrappedValue.count)
        return lengths.max() ?? 7
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(Array(document.commands.enumerated()), id: \.element) { offset, command in
                RebaseCommandView(command: Binding { command } set: { document.commands[offset] = $0 })
                    .contextMenu {
                        Button("Delete", action: onDelete)
                            .keyboardShortcut(.delete, modifiers: [])
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .contentShape(Rectangle())
            }
            .onMove { document.commands.move(fromOffsets: $0, toOffset: $1) }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("\(repo.directoryURL!.deletingLastPathComponent().lastPathComponent)  ›")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color(.windowFrameTextColor))
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selection.isEmpty)

                Button { showAddPopover = true } label: {
                    Image(systemName: "plus")
                }
                .popover(isPresented: $showAddPopover, arrowEdge: .bottom) {
                    AddCommandView(hashLength: hashLength) { command in
                        document.commands.insert(command, at: 0)
                        selection = [command]
                        showAddPopover = false
                    }
                }
            }
        }
        .environment(\.repo, repo)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(RebaseEditDocument(text: sample)), url: URL(fileURLWithPath: "/Users/jed/Documents/github-clones/Forks/PackageList/.git/rebase-merge/git-rebase-todo"))
    }
}
