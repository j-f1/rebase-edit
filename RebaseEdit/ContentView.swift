//
//  ContentView.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: RebaseEditDocument

    var body: some View {
        List(Array(document.commands.enumerated()), id: \.offset) { arg in
            RebaseCommandView(
                command: Binding { arg.element } set: { document.commands[arg.offset] = $0 }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(RebaseEditDocument(text: sample)))
    }
}
