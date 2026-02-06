//
//  NextToGoRacesApp.swift
//  NextToGoRaces
//
//  Created by Claude on 2026-02-06.
//

import NextToGoUI
import SwiftUI

@main
struct NextToGoRacesApp: App {

    // MARK: - Properties

    /// The dependency injection container
    @State private var container = DependencyContainer()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RacesListView(viewModel: container.racesViewModel)
                .task {
                    // Start background tasks when view appears
                    container.racesViewModel.startTasks()
                }
        }
    }

}
