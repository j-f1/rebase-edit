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

    static func findRepo(url: URL?) -> URL {
        let rebaseDir = url!.deletingLastPathComponent()
        let gitDir = rebaseDir.deletingLastPathComponent().path
        return URL(fileURLWithPath: String(gitDir), isDirectory: false)
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(Array(document.commands.enumerated()), id: \.element) { offset, command in
                RebaseCommandView(command: Binding { command } set: { document.commands[offset] = $0 })
                    .contextMenu {
                        Button("Delete") {
                            document.commands.removeAll(where: selection.contains)
                            selection = []
                        }
                    }
            }
            .onMove { document.commands.move(fromOffsets: $0, toOffset: $1) }
        }
        .environment(\.repo, repo)
        .onDeleteCommand {
            document.commands.removeAll { selection.contains($0) }
            selection = []
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("\(repo.directoryURL!.deletingLastPathComponent().lastPathComponent)  ›")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color(.windowFrameTextColor))
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    print("...")
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(RebaseEditDocument(text: sample)), url: URL(fileURLWithPath: "/Users/jed/Documents/github-clones/Forks/PackageList/.git/rebase-merge/git-rebase-todo"))
    }
}
