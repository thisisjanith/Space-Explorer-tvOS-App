//
//  SolarSystemView.swift
//  Janith-TVOS
//
//  Screen 2: The solar system. Swipe left/right to move between planets,
//  click to open a planet, Play/Pause to freeze the orbits.
//

import SwiftUI

/// Shows the animated orbit diagram above a row of eight planet cards.
/// The tvOS focus engine handles moving between cards; this view only tracks
/// which card is focused so the diagram and caption can follow it.
struct SolarSystemView: View {
    @Environment(AppRouter.self) private var router
    /// The planet card the Siri Remote is focused on (`nil` when a button has focus).
    @FocusState private var focusedPlanetID: String?
    /// The last focused planet. Kept separately so the caption stays when focus moves to the quiz button.
    @State private var highlighted: Planet = .earth
    @State private var isPaused = false

    var body: some View {
        ZStack {
            StarfieldBackground()

            VStack(spacing: 0) {
                header

                OrbitDiagram(highlightedID: highlighted.id, isPaused: isPaused)
                    .frame(height: 360)

                HStack(spacing: 18) {
                    ForEach(Planet.all) { planet in
                        PlanetCard(planet: planet, isPaused: isPaused) {
                            router.push(.planet(planet))
                        }
                        .focused($focusedPlanetID, equals: planet.id)
                    }
                }
                .padding(.top, 10)

                selectionCaption
                    .padding(.top, 34)
            }
            .padding(.horizontal, 10)
        }
        .defaultFocus($focusedPlanetID, Planet.earth.id)
        .onChange(of: focusedPlanetID) { _, id in
            if let id, let planet = Planet.with(id: id) {
                withAnimation(.easeInOut(duration: 0.25)) { highlighted = planet }
            }
        }
        .onPlayPauseCommand { isPaused.toggle() }
    }

    /// Title, remote hint and the Space Quiz shortcut.
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("SOLAR SYSTEM")
                    .font(Theme.display(64))
                    .foregroundStyle(Theme.titleGradient)
                Text(isPaused ? "Orbits paused — press Play/Pause to resume"
                              : "Swipe to choose a planet • Click to explore")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            SpaceButton("Space Quiz", systemImage: "questionmark.circle.fill", kind: .secondary) {
                router.push(.quiz)
            }
        }
    }

    /// Name, nickname and summary of the highlighted planet. Fades when the selection changes.
    private var selectionCaption: some View {
        VStack(spacing: 10) {
            HStack(spacing: 16) {
                Text(highlighted.name.uppercased())
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(.white)
                Text("•  \(highlighted.nickname)")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(highlighted.accentColor)
            }
            Text(highlighted.summary)
                .font(.system(size: 26, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: 1300)
        .id(highlighted.id)
        .transition(.opacity)
    }
}

#Preview {
    SolarSystemView()
        .environment(AppRouter())
}
