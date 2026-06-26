// Port of: MacDog.AppleScript/Honk.cs

import Foundation

@objc(HonkCommand)
final class Honk: ScriptCommand {
    override func PerformCommand() -> Any? {
        AppDelegate.SharedAppDelegate.gitDog?.PlaySound(.HONCC)
        return NSNumber(value: true)
    }
}
