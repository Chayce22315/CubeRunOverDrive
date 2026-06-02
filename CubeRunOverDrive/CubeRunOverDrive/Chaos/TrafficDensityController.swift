import Foundation

/// Ramps traffic over a run — tighter spawns and more cars at higher scores.
final class TrafficDensityController {
    private(set) var chaosLevel: Int = 0

    func reset() {
        chaosLevel = 0
    }

    func update(score: Int) {
        chaosLevel = min(10, score / 25)
    }

    var maxAlive: Int {
        8 + chaosLevel
    }

    var spawnIntervalRange: ClosedRange<TimeInterval> {
        let minimum = max(0.65, 1.55 - Double(chaosLevel) * 0.09)
        let maximum = max(minimum + 0.35, 2.85 - Double(chaosLevel) * 0.12)
        return minimum...maximum
    }

    /// 0...1 — higher means more cars vs blocks.
    var carSpawnWeight: Double {
        min(0.82, 0.45 + Double(chaosLevel) * 0.04)
    }
}
