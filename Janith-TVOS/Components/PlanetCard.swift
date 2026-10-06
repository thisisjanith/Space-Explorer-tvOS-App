//
//  PlanetCard.swift
//  Janith-TVOS
//
//  A focusable planet tile for the solar system screen. The focused planet
//  is enlarged and glows in its own colour.
//

import SwiftUI

struct PlanetCard: View {
    let planet: Planet
    /// Freezes the thumbnail's rotation.
    var isPaused: Bool = false
    /// Runs when the card is clicked.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // Thumbnail size follows the planet's relative size (compressed so Mercury stays visible).
            PlanetView(planet: planet, size: 48 + 72 * planet.displayScale, isPaused: isPaused)
        }
        .buttonStyle(PlanetCardStyle(planet: planet))
    }
}

private struct PlanetCardStyle: ButtonStyle {
    let planet: Planet

    func makeBody(configuration: Configuration) -> some View {
        PlanetCardBody(configuration: configuration, planet: planet)
    }
}

/// The card's appearance. A separate view is needed to read the `isFocused` environment value.
private struct PlanetCardBody: View {
    let configuration: ButtonStyleConfiguration
    let planet: Planet

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        VStack(spacing: 18) {
            configuration.label
                .frame(height: 150)
                .scaleEffect(isFocused ? 1.25 : 1)

            Text(planet.name.uppercased())
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .tracking(3)
                .foregroundStyle(isFocused ? .white : Theme.secondaryText)
        }
        .frame(width: 186, height: 250)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(isFocused ? planet.accentColor.opacity(0.22) : Color.white.opacity(0.04))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(isFocused ? planet.accentColor : .white.opacity(0.1), lineWidth: isFocused ? 4 : 1.5)
        }
        .shadow(color: planet.accentColor.opacity(isFocused ? 0.6 : 0), radius: 30)
        .scaleEffect(configuration.isPressed ? 1.02 : (isFocused ? 1.1 : 1))
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isFocused)
        .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    HStack(spacing: 18) {
        ForEach(Planet.all) { planet in
            PlanetCard(planet: planet) {}
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(StarfieldBackground())
}
