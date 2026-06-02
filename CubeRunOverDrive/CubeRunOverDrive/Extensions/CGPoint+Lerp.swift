import CoreGraphics

extension CGPoint {
    func lerp(to target: CGPoint, factor: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (target.x - x) * factor,
            y: y + (target.y - y) * factor
        )
    }
}
