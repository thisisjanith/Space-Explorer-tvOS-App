//
//  AppRouter.swift
//  Janith-TVOS
//
//  Drives the NavigationStack. The Siri Remote's Menu/Back button pops automatically.
//

import Observation

/// Every screen that can be pushed onto the navigation stack.
/// The Home screen is the stack's root, so it has no route.
enum Route: Hashable {
    /// Screen 2: the solar system and planet selection.
    case solarSystem
    /// Screen 3: information about one planet.
    case planet(Planet)
    /// Screen 4: the large rotating planet.
    case explore(Planet)
    /// Screen 5: "Did You Know?" facts.
    case facts(Planet)
    /// Screen 6: the Space Quiz.
    case quiz
}

/// Shared navigation state, injected into the view hierarchy with `.environment(_:)`.
/// Views call these methods instead of owning navigation logic themselves.
@Observable
final class AppRouter {
    /// The screens currently on the stack, bound to `NavigationStack(path:)`.
    var path: [Route] = []

    /// Opens a new screen on top of the current one.
    func push(_ route: Route) {
        path.append(route)
    }

    /// Goes back one screen (same as pressing Menu on the Siri Remote).
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Clears everything above the solar system screen, e.g. when leaving the quiz results.
    func popToSolarSystem() {
        path = [.solarSystem]
    }
}
