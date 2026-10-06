//
//  PausableTimeline.swift
//  Janith-TVOS
//
//  A TimelineView that can be paused (Play/Pause on the Siri Remote) and
//  resumed without the animation jumping ahead by the paused duration.
//

import SwiftUI

/// Calls `content` every frame with the current animation time in seconds.
///
/// While paused, the time stops advancing. On resume, the paused duration is
/// subtracted so the animation continues from exactly where it stopped.
struct PausableTimeline<Content: View>: View {
    private let isPaused: Bool
    private let minimumInterval: Double?
    private let content: (Double) -> Content

    /// When the current pause started, or `nil` while running.
    @State private var pausedAt: Date?
    /// Total time spent paused so far.
    @State private var pausedDuration: TimeInterval = 0

    /// - Parameters:
    ///   - isPaused: Freezes the animation while `true`.
    ///   - minimumInterval: Optional minimum seconds between frames; `nil` updates every display frame.
    ///   - content: Builds the view for a given animation time.
    init(isPaused: Bool = false, minimumInterval: Double? = nil, @ViewBuilder content: @escaping (Double) -> Content) {
        self.isPaused = isPaused
        self.minimumInterval = minimumInterval
        self.content = content
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: minimumInterval, paused: isPaused)) { context in
            let now = pausedAt ?? context.date
            content(now.timeIntervalSinceReferenceDate - pausedDuration)
        }
        .onChange(of: isPaused, initial: true) { _, paused in
            if paused {
                if pausedAt == nil { pausedAt = .now }
            } else if let start = pausedAt {
                pausedDuration += Date.now.timeIntervalSince(start)
                pausedAt = nil
            }
        }
    }
}
