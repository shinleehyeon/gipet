// Port of: MacDog.AppleScript/CollectNote.cs

import Foundation

@objc(CollectNoteCommand)
final class CollectNote: ScriptCommand {
    override func PerformCommand() -> Any? {
        AppDelegate.SharedAppDelegate.gitDog?.ShowNote(GetStringArg() ?? "", GetStringArg("title"))
        return NSNumber(value: true)
    }
}
