//
//  CommitSearchView.swift
//  RebaseEdit
//
//  Created by Jed Fox on 8/1/21.
//

import SwiftUI
import SwiftGit2

struct CommitSearchView<Picker: View>: View {
    let picker: Picker
    let onSelect: (Commit) -> Void

    @Environment(\.repo) private var repo

    @State private var text = ""
    @State private var found: Commit?
    @State private var db: ODB!
    @State private var matches: [Commit] = []

    var body: some View {
        VStack {
            HStack {
                picker
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
            }
            if let found = found {
                SelectButton {
                    onSelect(found)
                }
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
            } else {
                SelectButton {}.disabled(true)
            }
            if repo != nil {
                let commits = found?.parents
            } else {
                ProgressView()
                    .progressViewStyle(.linear)
            }
        }
        .onAppear {
            db = ODB(from: repo!)
        }
    }
}

struct CommitSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CommitSearchView(picker: Text("pick me"), onSelect: { _ in })
    }
}
