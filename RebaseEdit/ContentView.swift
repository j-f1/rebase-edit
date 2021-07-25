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

    static func findRepo(url: URL?) -> URL {
        let rebaseDir = url!.deletingLastPathComponent()
        let gitDir = rebaseDir.deletingLastPathComponent().path
        return URL(fileURLWithPath: String(gitDir), isDirectory: false)
    }

    var body: some View {
        List(Array(document.commands.enumerated()), id: \.offset) { arg in
            RebaseCommandView(
                command: Binding { arg.element } set: { document.commands[arg.offset] = $0 }
            )
        }.environment(\.repo, repo)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(RebaseEditDocument(text: sample)), url: URL(fileURLWithPath: "/Users/jed/Documents/github-clones/Forks/PackageList/.git/rebase-merge/git-rebase-todo"))
    }
}
