// Port of: MacDog/GitDogView.cs

import AppKit
import CoreGraphics

final class GitDogView: NSView {
    weak var dog: MacintoshGitDog?

    override func draw(_ dirtyRect: NSRect) {
        guard let g = NSGraphicsContext.current?.cgContext else { return }
        g.saveGState()
        dog?.Render(g)
        g.restoreGState()
    }
}
