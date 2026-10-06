//
//  FactsView.swift
//  Janith-TVOS
//
//  Screen 5: "Did You Know?" — step through interesting facts about a planet.
//

import SwiftUI

/// Shows one fact at a time on a large card. Previous/Next wrap around, so the
/// buttons never become disabled while focused (which would make focus jump).
struct FactsView: View {
    let planet: Planet

    @Environment(AppRouter.self) private var router
    /// Index into `planet.facts` of the fact on screen.
    @State private var factIndex = 0
    /// Direction of the last move; sets which way the card slides.
    @State private var movingForward = true

    var body: some View {
        ZStack {
            StarfieldBackground()

            VStack(spacing: 40) {
                VStack(spacing: 12) {
                    Label("DID YOU KNOW?", systemImage: "lightbulb.fill")
                        .font(Theme.display(64))
                        .foregroundStyle(Theme.titleGradient)
                    HStack(spacing: 20) {
                        PlanetView(planet: planet, size: 70)
                            .frame(width: 130, height: 90)
                        Text(planet.name.uppercased())
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .tracking(6)
                            .foregroundStyle(planet.accentColor)
                    }
                }

                factCard

                pageIndicator

                HStack(spacing: 30) {
                    SpaceButton("Previous", systemImage: "chevron.left", kind: .secondary) {
                        showFact(at: factIndex - 1)
                    }
                    SpaceButton("Next Fact", systemImage: "chevron.right") {
                        showFact(at: factIndex + 1)
                    }
                    SpaceButton("Space Quiz", systemImage: "questionmark.circle.fill", kind: .secondary) {
                        router.push(.quiz)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }

    /// The current fact. Changing `.id` makes SwiftUI treat each fact as a new view, so it slides in.
    private var factCard: some View {
        ZStack {
            Text(planet.facts[factIndex])
                .font(.system(size: 50, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 90)
                .id(factIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: movingForward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: movingForward ? .leading : .trailing).combined(with: .opacity)
                ))
        }
        .frame(maxWidth: 1400, minHeight: 340)
        .clipped()
        .background {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(LinearGradient(colors: [planet.accentColor.opacity(0.22), Theme.purple.opacity(0.12)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 2)
        }
    }

    /// Page dots plus an "X of Y" counter.
    private var pageIndicator: some View {
        HStack(spacing: 14) {
            ForEach(planet.facts.indices, id: \.self) { index in
                Capsule()
                    .fill(index == factIndex ? planet.accentColor : .white.opacity(0.25))
                    .frame(width: index == factIndex ? 48 : 16, height: 16)
            }
            Text("\(factIndex + 1) of \(planet.facts.count)")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.secondaryText)
                .padding(.leading, 10)
        }
    }

    /// Moves to another fact, wrapping around at either end.
    private func showFact(at index: Int) {
        let count = planet.facts.count
        movingForward = index > factIndex
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            factIndex = (index % count + count) % count
        }
    }
}

#Preview {
    FactsView(planet: .jupiter)
        .environment(AppRouter())
}
