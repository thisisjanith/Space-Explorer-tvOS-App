//
//  PlanetDetailView.swift
//  Janith-TVOS
//
//  Screen 3: Planet information. One reusable view for all eight planets.
//

import SwiftUI

/// Shows the planet on the left and its statistics on the right, with buttons
/// to open the exploration and facts screens. The planet scales up as the screen opens.
struct PlanetDetailView: View {
    let planet: Planet

    @Environment(AppRouter.self) private var router
    /// Drives the scale-up entrance animation.
    @State private var appeared = false
    @State private var isPaused = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 22), count: 3)

    /// Ringed planets are drawn smaller so their rings stay clear of the text.
    private var planetSize: CGFloat {
        guard let rings = planet.appearance.rings else { return 480 }
        return min(480, 680 / rings.outerRadius)
    }

    var body: some View {
        ZStack {
            StarfieldBackground()

            RadialGradient(colors: [planet.accentColor.opacity(0.25), .clear],
                           center: UnitPoint(x: 0.25, y: 0.5), startRadius: 0, endRadius: 700)
                .ignoresSafeArea()

            HStack(spacing: 70) {
                PlanetView(planet: planet, size: planetSize, isPaused: isPaused)
                    .frame(width: 640)
                    .scaleEffect(appeared ? 1 : 0.35)
                    .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PLANET \(planet.order) OF 8")
                            .eyebrowStyle(planet.accentColor)
                        Text(planet.name.uppercased())
                            .font(Theme.display(96))
                            .foregroundStyle(.white)
                        Text(planet.nickname)
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundStyle(planet.accentColor)
                    }

                    Text(planet.summary)
                        .font(.system(size: 28, weight: .regular, design: .rounded))
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: columns, spacing: 22) {
                        StatTile(title: "From the Sun", value: planet.distanceFromSun, systemImage: "sun.max.fill", tint: planet.accentColor)
                        StatTile(title: "Diameter", value: planet.diameter, systemImage: "circle.dashed", tint: planet.accentColor)
                        StatTile(title: "Temperature", value: planet.temperature, systemImage: "thermometer.medium", tint: planet.accentColor)
                        StatTile(title: "Moons", value: "\(planet.moons)", systemImage: "moon.fill", tint: planet.accentColor)
                        StatTile(title: "Day Length", value: planet.dayLength, systemImage: "clock.fill", tint: planet.accentColor)
                        StatTile(title: "Year Length", value: planet.yearLength, systemImage: "calendar", tint: planet.accentColor)
                    }

                    HStack(spacing: 30) {
                        SpaceButton("Explore Planet", systemImage: "rotate.3d") {
                            router.push(.explore(planet))
                        }
                        SpaceButton("Did You Know?", systemImage: "lightbulb.fill", kind: .secondary) {
                            router.push(.facts(planet))
                        }
                    }
                    .padding(.top, 8)
                }
                .offset(x: appeared ? 0 : 60)
                .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                appeared = true
            }
        }
        .onPlayPauseCommand { isPaused.toggle() }
    }
}

#Preview {
    PlanetDetailView(planet: .earth)
        .environment(AppRouter())
}
