//
//  PlanetAnimationView.swift
//  Janith-TVOS
//
//  Screen 4: Planet exploration. A large rotating planet with its moons.
//  Play/Pause on the Siri Remote freezes and resumes the animation.
//

import SwiftUI

/// Full-screen view of one planet spinning, with its moons and key rotation facts.
struct PlanetAnimationView: View {
    let planet: Planet

    @Environment(AppRouter.self) private var router
    @State private var isPaused = false
    @State private var appeared = false

    /// Ringed planets are drawn smaller so the rings fit on screen.
    private var planetSize: CGFloat {
        guard let rings = planet.appearance.rings else { return 540 }
        return min(540, 1100 / rings.outerRadius)
    }

    private var spinDescription: String {
        planet.spinDirection < 0 ? "Spins backwards" : "Spins forwards"
    }

    var body: some View {
        ZStack {
            StarfieldBackground()

            RadialGradient(colors: [planet.accentColor.opacity(0.22), .clear],
                           center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()

            PlanetView(planet: planet, size: planetSize, isPaused: isPaused, showsMoons: true)
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .offset(y: 10)

            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("EXPLORING")
                            .eyebrowStyle(planet.accentColor)
                        Text(planet.name.uppercased())
                            .font(Theme.display(80))
                            .foregroundStyle(.white)
                        Label(isPaused ? "Paused" : "Rotating Planet",
                              systemImage: isPaused ? "pause.circle.fill" : "arrow.clockwise.circle.fill")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundStyle(isPaused ? Theme.secondaryText : planet.accentColor)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 18) {
                        infoRow(title: "One spin", value: planet.dayLength)
                        infoRow(title: "Axis tilt", value: planet.axialTilt)
                        infoRow(title: "Direction", value: spinDescription)
                        infoRow(title: "Moons", value: moonDescription)
                    }
                }

                Spacer()

                HStack(spacing: 30) {
                    SpaceButton("Back", systemImage: "chevron.left", kind: .secondary) {
                        router.pop()
                    }
                    SpaceButton(isPaused ? "Play" : "Pause",
                                systemImage: isPaused ? "play.fill" : "pause.fill",
                                kind: .secondary) {
                        isPaused.toggle()
                    }
                    SpaceButton("Facts", systemImage: "lightbulb.fill") {
                        router.push(.facts(planet))
                    }
                }

                Text("Tip: press Play/Pause on the Siri Remote to freeze the planet")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.top, 18)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .onPlayPauseCommand { isPaused.toggle() }
    }

    /// At most four moons are animated, so larger counts say how many are shown.
    private var moonDescription: String {
        switch planet.moons {
        case 0: "None"
        case 1...4: "\(planet.moons)"
        default: "\(planet.moons) (4 shown)"
        }
    }

    /// A right-aligned label/value pair in the top-right info panel.
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .tracking(3)
                .foregroundStyle(planet.accentColor)
            Text(value)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    PlanetAnimationView(planet: .saturn)
        .environment(AppRouter())
}
