//
//  PromtSaverApp.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//

import SwiftUI

@main
struct PromtSaverApp: App {
    @State private var store = PromptNoteStore(notes: PromptNoteMockList.all)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
