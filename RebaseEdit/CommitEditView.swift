//
//  CommitEditView.swift
//  SwiftGit2-OSX
//
//  Created by Jed Fox on 7/25/21.
//  Copyright © 2021 GitHub, Inc. All rights reserved.
//

import SwiftUI
import SwiftGit2

func firstLine(of message: String) -> some StringProtocol {
    message.prefix(upTo: (message.firstIndex(of: "\n") ?? message.endIndex))
}

struct CommitEditView: View {
    let canEdit: Bool
	 @Binding var sha: String
    @Binding var state: RebaseState

    @Environment(\.repo) private var repo: Repository!
    @State private var commit: Commit?

    @State private var isEditing = false

	 var body: some View {
        HStack {
            if let commit = commit {
                Text(sha)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                Text(firstLine(of: state.message ?? commit.message))
                    .lineLimit(1)
                if canEdit && FeatureFlag[.editMessage] {
                    Button(action: { isEditing = true }) {
                        Text("edit")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $isEditing, arrowEdge: .bottom) {
                        VStack {
                            TextEditor(text: Binding { state.message ?? commit.message } set: { state.message = $0 })
                                .frame(width: 250, height: 150)
                        }
                        .padding(5)
                        .background(Color(NSColor.textBackgroundColor))
                    }
                }
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
            }
        }
        .onAppear {
            if let odb = ODB(from: repo),
               let oid = odb[sha] {
                commit = try? repo.commit(oid).get()
            }
        }
    }
}

struct CommitEditView_Previews: PreviewProvider {
    static var previews: some View {
        CommitEditView(canEdit: true, sha: .constant("2111d70"), state: .constant(RebaseState()))
            .environment(\.repo, try! Repository.at(URL(fileURLWithPath: "/Users/jed/Documents/github-clones/Forks/PackageList/.git/rebase-merge/git-rebase-todo")).get())
    }
}
