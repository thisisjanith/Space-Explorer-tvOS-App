//
//  HomeView.swift
//  Janith-TVOS
//
//  Screen 1: Welcome screen.
//

import SwiftUI

/// The first screen: app title, decorative planets, and buttons to start exploring or jump to the quiz.
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    /// Drives the entrance animation when the screen first appears.
    @State private var appeared = false

    var body: some View {
        ZStack {
            StarfieldBackground()

            PlanetView(planet: .saturn, size: 440)
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .offset(x: 470, y: -40)

            PlanetView(planet: .earth, size: 150, showsMoons: true)
                .opacity(appeared ? 1 : 0)
                .offset(x: 190, y: 330)

            HStack {
                VStack(alignment: .leading, spacing: 30) {
                    Label("AN INTERACTIVE SOLAR SYSTEM", systemImage: "sparkles")
                        .eyebrowStyle()

                    Text("SPACE\nEXPLORER")
                        .font(Theme.display(150))
                        .lineSpacing(-30)
                        .foregroundStyle(Theme.titleGradient)
                        .shadow(color: Theme.purple.opacity(0.5), radius: 30)

                    Text("Explore the planets, watch them spin,\ndiscover amazing facts and test your knowledge.")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.secondaryText)

                    HStack(spacing: 36) {
                        SpaceButton("Start", systemImage: "play.fill") {
                            router.push(.solarSystem)
                        }
                        SpaceButton("Space Quiz", systemImage: "questionmark.circle.fill", kind: .secondary) {
                            router.push(.quiz)
                        }
                    }
                    .padding(.top, 20)

                    Label("Swipe to move  •  Click to select  •  Menu to go back", systemImage: "appletvremote.gen4")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 20)
                }
                .offset(y: appeared ? 0 : 40)
                .opacity(appeared ? 1 : 0)

                Spacer()
            }
            .padding(.horizontal, 100)
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
}
