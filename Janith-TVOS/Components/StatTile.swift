//
//  StatTile.swift
//  Janith-TVOS
//

import SwiftUI

/// A labelled statistic, e.g. "MOONS · 1", used in the planet details grid.
struct StatTile: View {
    /// Small label shown in capitals above the value.
    let title: String
    let value: String
    /// SF Symbol name shown next to the title.
    let systemImage: String
    /// Colour of the title and icon, usually the planet's accent colour.
    var tint: Color = Theme.blue

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title.uppercased(), systemImage: systemImage)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.06))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1.5)
        }
        .accessibilityElement(children: .combine)
    }
}
