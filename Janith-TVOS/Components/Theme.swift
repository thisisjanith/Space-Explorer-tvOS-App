//
//  Theme.swift
//  Janith-TVOS
//
//  Colours and type styles tuned for reading from across the room.
//

import SwiftUI

/// The app's shared colour palette and fonts (dark navy, blue and purple, from the design plan).
/// Using these constants everywhere keeps every screen visually consistent.
enum Theme {
    static let deepSpace = Color(red: 0.01, green: 0.02, blue: 0.06)
    static let navy = Color(red: 0.04, green: 0.07, blue: 0.2)
    static let blue = Color(red: 0.36, green: 0.64, blue: 1.0)
    static let purple = Color(red: 0.62, green: 0.45, blue: 1.0)
    static let success = Color(red: 0.3, green: 0.85, blue: 0.5)
    static let danger = Color(red: 1.0, green: 0.38, blue: 0.4)
    static let secondaryText = Color.white.opacity(0.7)

    /// White-to-purple gradient used for large screen titles.
    static let titleGradient = LinearGradient(
        colors: [.white, Color(red: 0.75, green: 0.82, blue: 1.0), purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Heavy rounded font for headings, large enough to read from the sofa.
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
}

extension View {
    /// Small all-caps label used above headings ("PLANET 3 OF 8", "DID YOU KNOW?").
    func eyebrowStyle(_ color: Color = Theme.blue) -> some View {
        font(.system(size: 26, weight: .bold, design: .rounded))
            .tracking(6)
            .foregroundStyle(color)
    }
}
