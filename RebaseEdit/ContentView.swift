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
        Text("Hello, world!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(RebaseEditDocument()))
    }
}
