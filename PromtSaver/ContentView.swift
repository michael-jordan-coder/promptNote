//
//  ContentView.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List(PromptNoteMockList.all) { note in
            PromptNoteView(note: note)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(.plain)
    }
}

#Preview {
    ContentView()
}
