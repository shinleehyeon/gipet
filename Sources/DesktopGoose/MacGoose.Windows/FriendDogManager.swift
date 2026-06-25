import Foundation
import AppKit

private final class FriendDog {
    let dog: MacintoshGoose
    init(_ dog: MacintoshGoose) { self.dog = dog }
}

final class FriendDogManager {
    static let shared = FriendDogManager()
    private var friends: [FriendDog] = []

    private static let lines0: [String] = [
        "얘 진짜\n개발자 맞아? ㅋㅋ",
        "얘 깃허브\n잔디 진짜 없더라",
        "얘 오늘도\n커밋 0개래 ㅋㅋ",
        "얘 IDE는\n켜기나 해? ㅋ",
        "얘 코드가\n뭔지는 알아? ㅋ",
        "얘 키보드\n먼지 쌓이겠다",
        "얘 이번달도\n아무것도 안했대",
    ]
    private static let lines1: [String] = [
        "ㄹㅇ ㅋㅋ\n걍 접어라",
        "ㅋㅋ 진짜\n구제불능이다",
        "ㄹㅇㅋㅋ 얘\n 왜안함?",
        "ㅋㅋ \n쪽팔리다",
        "ㅋㅋㅋ 걍\n 접어",
        "진짜 ㅋㅋ\n뭐하러 깔았대",
        "ㄹㅇ 얘 \n왜 안하고 있냐",
    ]

    private static let exitLines: [[String]] = [
        ["에휴\n가야지 ㅉㅉ", "ㅋㅋ 가자 ㅉㅉ", "나 간다\n잘 있어 ㅉㅉ", "에휴 ㅉㅉ.."],
        ["ㅋㅋ 나도\n가야겠다 ㅉㅉ", "ㅉㅉ", "ㅋ 잘있어 ㅉㅉ", "에휴 참..ㅉㅉ"],
    ]

    private enum SpawnEdge { case left, right, top }
    private var spawnEdge: SpawnEdge = .left
    private init() {}

    // Spawns 2 friend dogs from the same off-screen position as the main dog.
    // `pos` is the main dog's position at the moment it turned back (deep off-screen).
    func spawnFriends(near pos: Vector2, screenWidth w: Float, screenHeight h: Float) {
        for f in friends { f.dog.dismiss() }
        friends = []

        let distL = pos.x
        let distR = w - pos.x
        let distT = pos.y

        let startPositions: [Vector2]
        let targetPositions: [Vector2]
        let inset: Float = 170

        if distT < distL && distT < distR {
            spawnEdge = .top
            startPositions = [
                Vector2(max(60, pos.x - 60), pos.y),
                Vector2(min(w - 60, pos.x + 60), pos.y),
            ]
            targetPositions = [
                Vector2(startPositions[0].x, inset),
                Vector2(startPositions[1].x, inset),
            ]
        } else if distL <= distR {
            spawnEdge = .left
            startPositions = [
                Vector2(pos.x, max(60, pos.y - 60)),
                Vector2(pos.x, min(h - 60, pos.y + 60)),
            ]
            targetPositions = [
                Vector2(inset, startPositions[0].y),
                Vector2(inset, startPositions[1].y),
            ]
        } else {
            spawnEdge = .right
            startPositions = [
                Vector2(pos.x, max(60, pos.y - 60)),
                Vector2(pos.x, min(h - 60, pos.y + 60)),
            ]
            targetPositions = [
                Vector2(w - inset, startPositions[0].y),
                Vector2(w - inset, startPositions[1].y),
            ]
        }

        for i in 0..<2 {
            let dog = MacintoshGoose(memesDirectory: "", notesDirectory: "")
            dog.makeExternallyManaged()
            dog.swapCharacter(to: .chick)
            dog.coatVariant = i + 1
            dog.position = startPositions[i]
            dog.walkTo(targetPositions[i]) {
                dog.velocity = .zero
                dog.targetPos = dog.position       // clear stale dest so toTarget = 0
                dog.lockedTarget = dog.position
                dog.onLockedTargetArrival = nil
                dog.targetDirection = Vector2(0, 1)
            }
            dog.currentSpeed = 80
            friends.append(FriendDog(dog))
        }
    }

    // Called when main dog enters the Chatting stage.
    func startDialogue() {
        guard friends.count >= 2 else { return }
        let f0 = friends[0]
        let f1 = friends[1]
        let line0 = Self.lines0.randomElement()!
        let line1 = Self.lines1.randomElement()!

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            f0.dog.Say(line0, duration: 4.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            f1.dog.Say(line1, duration: 3.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) { [weak self] in
            self?.walkFriendsOffscreen()
        }
    }

    private func walkFriendsOffscreen() {
        let w = friends.first?.dog.GetMainWindowWidth() ?? 1440
        for (i, f) in friends.enumerated() {
            let delay = Double(i) * 2.0
            let line = Self.exitLines[i].randomElement()!
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                f.dog.Say(line, duration: 2.5)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 1.8) { [weak self] in
                guard let self else { return }
                let offTarget: Vector2
                switch self.spawnEdge {
                case .left:  offTarget = Vector2(-90, f.dog.position.y)
                case .right: offTarget = Vector2(w + 90, f.dog.position.y)
                case .top:   offTarget = Vector2(f.dog.position.x, -90)
                }
                f.dog.walkTo(offTarget) { [weak self] in
                    f.dog.dismiss()
                    self?.friends.removeAll { $0 === f }
                }
                f.dog.currentSpeed = 80
            }
        }
    }

    // Called each frame by MacintoshGoose's tick timer.
    func tickAll() {
        for f in friends {
            f.dog.tickAndRedraw()
        }
    }
}
