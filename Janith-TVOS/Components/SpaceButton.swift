//
//  SpaceButton.swift
//  Janith-TVOS
//
//  Large capsule buttons with a strong focus state for the Siri Remote.
//

import SwiftUI

/// The app's standard button: a capsule that turns white, grows and glows when focused,
/// so it's obvious from across the room which button the Siri Remote will press.
struct SpaceButton: View {
    /// Visual emphasis of the button.
    enum Kind {
        /// Blue-purple gradient, for the main action on a screen.
        case primary
        /// Translucent, for supporting actions.
        case secondary
    }

    let title: String
    var systemImage: String?
    var kind: Kind = .primary
    let action: () -> Void

    /// - Parameters:
    ///   - title: Button text.
    ///   - systemImage: Optional SF Symbol name shown before the text.
    ///   - kind: Primary or secondary styling.
    ///   - action: Runs when the button is clicked on the Siri Remote.
    init(_ title: String, systemImage: String? = nil, kind: Kind = .primary, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.kind = kind
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
        }
        .buttonStyle(SpaceButtonStyle(kind: kind))
    }
}

/// Button style behind `SpaceButton`. A custom style replaces tvOS's default
/// focus effect, so the focused look is drawn in `SpaceButtonBody`.
struct SpaceButtonStyle: ButtonStyle {
    var kind: SpaceButton.Kind = .primary

    func makeBody(configuration: Configuration) -> some View {
        SpaceButtonBody(configuration: configuration, kind: kind)
    }
}

/// A separate view so it can read the focus environment of the button.
private struct SpaceButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: SpaceButton.Kind

    @Environment(\.isFocused) private var isFocused
    @Environment(\.isEnabled) private var isEnabled

    private var restingFill: AnyShapeStyle {
        switch kind {
        case .primary:
            AnyShapeStyle(LinearGradient(colors: [Theme.blue, Theme.purple], startPoint: .leading, endPoint: .trailing))
        case .secondary:
            AnyShapeStyle(Color.white.opacity(0.1))
        }
    }

    var body: some View {
        configuration.label
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .tracking(1)
            .foregroundStyle(isFocused ? Theme.deepSpace : .white)
            .padding(.horizontal, 52)
            .padding(.vertical, 22)
            .background {
                Capsule().fill(isFocused ? AnyShapeStyle(Color.white) : restingFill)
            }
            .overlay {
                Capsule().strokeBorder(.white.opacity(isFocused ? 0 : 0.3), lineWidth: 2)
            }
            .shadow(color: Theme.blue.opacity(isFocused ? 0.7 : 0), radius: 28)
            .scaleEffect(configuration.isPressed ? 0.95 : (isFocused ? 1.1 : 1))
            .opacity(isEnabled ? 1 : 0.35)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    HStack(spacing: 40) {
        SpaceButton("Start", systemImage: "play.fill") {}
        SpaceButton("Space Quiz", systemImage: "questionmark.circle", kind: .secondary) {}
    }
    .padding(80)
    .background(StarfieldBackground())
}
