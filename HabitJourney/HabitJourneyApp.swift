//
//  HabitJourneyApp.swift
//  HabitJourney
//
//  Created by Luca Barone on 20/6/25.
//

import SwiftUI
import SwiftData

@main
struct HabitJourneyApp: App {
    private var container: ModelContainer = ModelController.shared.container

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
