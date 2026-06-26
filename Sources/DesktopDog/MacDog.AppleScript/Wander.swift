// Port of: MacDog.AppleScript/Wander.cs

import Foundation

@objc(WanderCommand)
final class Wander: ScriptCommand {
    override func PerformCommand() -> Any? {
        guard let dog = AppDelegate.SharedAppDelegate.gitDog else { return NSNumber(value: false) }
        dog.ScheduledWanderTime = GetFloatArg("duration")
        dog.SetTask(.Wander, honck: false)
        return NSNumber(value: true)
    }
}
