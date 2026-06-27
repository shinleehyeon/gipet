// Port of: MacDog/MacDogSettings.cs

import Foundation
import AppKit
import CoreGraphics

final class MacDogSettings: GitDogConfig.ConfigSettings {
    static let CanAttackAtRandomKey = "CanAttackAtRandom"
    static let MinWanderingTimeKey  = "MinWanderingTimeSeconds"
    static let MaxWanderingTimeKey  = "MaxWanderingTimeSeconds"
    static let FirstWanderTimeKey   = "FirstWanderTimeSeconds"
    static let FrameRateKey         = "FrameRate"
    static let UseCustomColorsKey   = "UseCustomColors"
    static let WhiteColorKey        = "DogWhite"
    static let OrangeColorKey       = "DogOrange"
    static let OutlineColorKey      = "DogOutline"
    static let EyeColorKey          = "DogEye"
    static let MudColorKey          = "DogMud"
    static let SoundVolumeKey       = "SoundVolume"

    private static let WhiteColorDefault   = "#ffffff"
    private static let OrangeColorDefault  = "#ffa500"
    private static let OutlineColorDefault = "#d3d3d3"
    private static let EyeColorDefault     = "#000000"
    private static let MudColorDefault     = "#8b4513"

    private var observers: [NSObjectProtocol] = []

    var UseCustomColors: Bool = false

    override var CanAttackAtRandom: Bool {
        get { UserDefaults.standard.bool(forKey: MacDogSettings.CanAttackAtRandomKey) }
        set { super.CanAttackAtRandom = newValue }
    }
    override var MinWanderingTimeSeconds: Float {
        get { UserDefaults.standard.float(forKey: MacDogSettings.MinWanderingTimeKey) }
        set { super.MinWanderingTimeSeconds = newValue }
    }
    override var MaxWanderingTimeSeconds: Float {
        get { UserDefaults.standard.float(forKey: MacDogSettings.MaxWanderingTimeKey) }
        set { super.MaxWanderingTimeSeconds = newValue }
    }
    override var FirstWanderTimeSeconds: Float {
        get { UserDefaults.standard.float(forKey: MacDogSettings.FirstWanderTimeKey) }
        set { super.FirstWanderTimeSeconds = newValue }
    }
    override var FrameRate: Float {
        get { UserDefaults.standard.float(forKey: MacDogSettings.FrameRateKey) }
        set { super.FrameRate = newValue }
    }

    private(set) var DogWhite:   CGColor!
    private(set) var DogOrange:  CGColor!
    private(set) var DogOutline: CGColor!
    private(set) var DogEye:     CGColor!
    private(set) var DogMud:     CGColor!

    override init() {
        super.init()
        let d = UserDefaults.standard
        d.register(defaults: [
            MacDogSettings.CanAttackAtRandomKey: false,
            // User-tuned: bring memes more often → shorter wander interludes.
            MacDogSettings.MinWanderingTimeKey:  Float(120),
            MacDogSettings.MaxWanderingTimeKey:  Float(120),
            MacDogSettings.FirstWanderTimeKey:   Float(120),
            MacDogSettings.FrameRateKey:         Float(60),
            MacDogSettings.UseCustomColorsKey:   false,
            MacDogSettings.WhiteColorKey:        MacDogSettings.WhiteColorDefault,
            MacDogSettings.OrangeColorKey:       MacDogSettings.OrangeColorDefault,
            MacDogSettings.OutlineColorKey:      MacDogSettings.OutlineColorDefault,
            MacDogSettings.EyeColorKey:          MacDogSettings.EyeColorDefault,
            MacDogSettings.MudColorKey:          MacDogSettings.MudColorDefault,
            MacDogSettings.SoundVolumeKey:       Float(1)
        ])
        LoadColors()

        let nc = NotificationCenter.default
        // Listen for any UserDefaults change — reload colors.
        let token = nc.addObserver(forName: UserDefaults.didChangeNotification,
                                   object: d, queue: .main) { [weak self] _ in
            self?.LoadColors()
        }
        observers.append(token)
    }

    deinit {
        for o in observers { NotificationCenter.default.removeObserver(o) }
    }

    private func LoadColors() {
        let d = UserDefaults.standard
        UseCustomColors = d.bool(forKey: MacDogSettings.UseCustomColorsKey)
        if UseCustomColors {
            DogWhite   = MacDogSettings.ColorFromHexString(d.string(forKey: MacDogSettings.WhiteColorKey)   ?? MacDogSettings.WhiteColorDefault)
            DogOrange  = MacDogSettings.ColorFromHexString(d.string(forKey: MacDogSettings.OrangeColorKey)  ?? MacDogSettings.OrangeColorDefault)
            DogOutline = MacDogSettings.ColorFromHexString(d.string(forKey: MacDogSettings.OutlineColorKey) ?? MacDogSettings.OutlineColorDefault)
            DogEye     = MacDogSettings.ColorFromHexString(d.string(forKey: MacDogSettings.EyeColorKey)     ?? MacDogSettings.EyeColorDefault)
            DogMud     = MacDogSettings.ColorFromHexString(d.string(forKey: MacDogSettings.MudColorKey)     ?? MacDogSettings.MudColorDefault)
        } else {
            DogWhite   = MacDogSettings.ColorFromHexString(MacDogSettings.WhiteColorDefault)
            DogOrange  = MacDogSettings.ColorFromHexString(MacDogSettings.OrangeColorDefault)
            DogOutline = MacDogSettings.ColorFromHexString(MacDogSettings.OutlineColorDefault)
            DogEye     = MacDogSettings.ColorFromHexString(MacDogSettings.EyeColorDefault)
            DogMud     = MacDogSettings.ColorFromHexString(MacDogSettings.MudColorDefault)
        }
    }

    static func ColorFromHexString(_ hexString: String) -> CGColor {
        let text = hexString.replacingOccurrences(of: "#", with: "")
        let num = Int(text, radix: 16) ?? 0
        var r: Float = 0, g: Float = 0, b: Float = 0
        switch text.count {
        case 3:
            r = Float((num & 0xF00) >> 8) / 15
            g = Float((num & 0xF0)  >> 4) / 15
            b = Float(num & 0xF)           / 15
        case 6:
            r = Float((num & 0xFF0000) >> 16) / 255
            g = Float((num & 0xFF00)   >> 8)  / 255
            b = Float(num & 0xFF)              / 255
        default: break
        }
        return CGColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
    }
}
