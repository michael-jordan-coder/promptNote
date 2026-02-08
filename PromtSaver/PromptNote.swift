//
//  PromptNote.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//
import SwiftUI

struct PromptNote: Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
}
