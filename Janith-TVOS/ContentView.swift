//
//  ContentView.swift
//  Janith-TVOS
//
//  Root navigation for Space Explorer.
//

import SwiftUI

/// The app's root view: a `NavigationStack` starting at the Home screen.
/// Each `Route` maps to one screen; pressing Menu on the Siri Remote pops back.
struct ContentView: View {
    /// Shared with every screen through the environment so any screen can navigate.
    @State private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .solarSystem:
                        SolarSystemView()
                    case .planet(let planet):
                        PlanetDetailView(planet: planet)
                    case .explore(let planet):
                        PlanetAnimationView(planet: planet)
                    case .facts(let planet):
                        FactsView(planet: planet)
                    case .quiz:
                        QuizView()
                    }
                }
        }
        .environment(router)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
