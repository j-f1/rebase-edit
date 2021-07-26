//
//  CommitSearchField.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI
import SwiftGit2
import Introspect

struct CommitSearchField: View {

    let onSelect: (Commit) -> ()

    @State private var text = ""
    @Environment(\.repo) private var repo

    @State private var found: Commit?
    @State private var db: ODB!
    @State private var matches: [Commit] = []

    var body: some View {
        VStack {
            TextField("Type or paste commit hash…", text: $text)
                .onChange(of: text) { newValue in
                    found = try? repo.flatMap { db[newValue].map($0.commit) }?.get()
                }
                .overlay(Group {
                    if found != nil {
                        Image(systemName: "return")
                            .font(.body.bold())
                            .foregroundColor(.green)
                            .help("Press enter to select")
                            .padding(.trailing, 3)
                    }
                }, alignment: .trailing)
                .introspectTextField { tf in
                    tf.becomeFirstResponder()
                }
            if let found = found {
                HStack {
                    Text(found.message.trimmingCharacters(in: .whitespacesAndNewlines))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(.system(.caption, design: .monospaced))
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                Button {
                    onSelect(found)
                } label: {
                    HStack {
                        Spacer(minLength: 0)
                        Text("Add to rebase")
                            .truncationMode(.middle)
                        Spacer(minLength: 0)
                    }
                    .frame(width: 238)
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)
            }
            if repo != nil {
                let commits = found?.parents
            } else {
                ProgressView()
                    .progressViewStyle(.linear)
            }
        }
        .frame(width: 250)
        .padding(10)
        .onAppear {
            db = ODB(from: repo!)
        }
    }
}

struct CommitSearchField_Previews: PreviewProvider {
    static var previews: some View {
        CommitSearchField(onSelect: { _ in })
    }
}
