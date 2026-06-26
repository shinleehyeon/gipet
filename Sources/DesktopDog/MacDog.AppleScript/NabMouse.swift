// Port of: MacDog.AppleScript/NabMouse.cs

import Foundation

@objc(NabMouseCommand)
final class NabMouse: ScriptCommand {
    override func PerformCommand() -> Any? {
        AppDelegate.SharedAppDelegate.gitDog?.SetTask(.NabMouse, honck: false)
        return NSNumber(value: true)
    }
}
