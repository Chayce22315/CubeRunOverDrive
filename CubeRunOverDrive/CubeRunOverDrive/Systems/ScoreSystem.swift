import Foundation

/// Distance-based score.
final class ScoreSystem {
    private(set) var score = 0
    let pointsPerUnit: CGFloat = 10

    func reset() {
        score = 0
    }

    func update(playerX: CGFloat, startX: CGFloat, isPlaying: Bool) {
        guard isPlaying else { return }
        let distance = max(0, playerX - startX)
        score = Int(distance / pointsPerUnit)
    }
}
