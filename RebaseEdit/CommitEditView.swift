//
//  CommitEditView.swift
//  SwiftGit2-OSX
//
//  Created by Jed Fox on 7/25/21.
//  Copyright © 2021 GitHub, Inc. All rights reserved.
//

import SwiftUI
import SwiftGit2

extension Commit {
    var summary: some StringProtocol {
        message.prefix(upTo: (message.firstIndex(of: "\n") ?? message.endIndex))
    }
}

struct CommitEditView: View {
	 @Binding var sha: String
    @Environment(\.repo) var repo: Repository!

    @State var commit: Commit?

	 var body: some View {
        HStack {
            if let commit = commit {
                Text(sha)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                Text(commit.summary)
                    .lineLimit(1)
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
        CommitEditView(sha: .constant("2111d70"))
            .environment(\.repo, try! Repository.at(URL(fileURLWithPath: "/Users/jed/Documents/github-clones/Forks/PackageList/.git/rebase-merge/git-rebase-todo")).get())
    }
}
