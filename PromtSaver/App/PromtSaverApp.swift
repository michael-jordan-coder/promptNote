//
//  PromtSaverApp.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//

import SwiftUI
import SwiftData

@main
struct PromtSaverApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PromptNote.self)
    }
}
