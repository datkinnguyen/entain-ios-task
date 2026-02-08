//
//  NextToGoRacesApp.swift
//  NextToGoRaces
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
                    container.racesViewModel.startTasks()
                }
        }
    }

}
