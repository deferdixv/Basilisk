//
//  SyllabusApp.swift
//  Syllabus
//

import SwiftUI
import BasiliskCore
import BasiliskUI

@main
struct SyllabusApp: App {

    @State private var environment: AppEnvironment
    @State private var store: SyllabusStore

    init() {
        let env = AppEnvironment()
        _environment = State(initialValue: env)
        _store = State(initialValue: SyllabusStore(env: env))
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(environment)
                .environment(store)
                .frame(minWidth: 1000, minHeight: 620)
                .task { store.syncWithFinder() }
        }
        .windowResizability(.contentMinSize)
    }
}
