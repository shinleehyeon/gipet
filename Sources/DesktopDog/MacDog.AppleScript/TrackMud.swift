// Port of: MacDog.AppleScript/TrackMud.cs

import Foundation

@objc(TrackMudCommand)
final class TrackMud: ScriptCommand {
    override func PerformCommand() -> Any? {
        AppDelegate.SharedAppDelegate.gitDog?.SetTask(.TrackMud, honck: false)
        return NSNumber(value: true)
    }
}
