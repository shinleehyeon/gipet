// Local addition — 아재개그 lines the dog says (via a speech bubble) when it
// detects you've committed today (or via the "말풍선 💬" menu item). Kept short
// and pre-wrapped with "\n" so the bubble never grows past the character view.

import Foundation

enum DadJokes {
    static let lines: [String] = [
        "넋이 나가 있는\n벌레는?\n헤벌레",
        "참새가 먹는\n간식은?\n새참",
        "집보다 높이 뛰는\n사람은?\n모든 사람\n(집은 못 뛰니까)",
        "나면서부터\n늙은 것은?\n할미꽃",
        "날마다 떼돈을\n버는 사람은?\n목욕탕 주인",
        "날아다니는\n꼬리는?\n꾀꼬리",
        "심마니들이 좋아하는\n물은?\n삼다수",
        "화장한 쥐가 비를\n보는 걸 6자로?\n화장지는비봐",
        "시가 현실적이면?\n시리얼",
        "이쪽 벽이\n저쪽 벽에게 한 말은?\n구석에서 만나",
        "못생긴 사람이\n오이 마사지하면?\n호박전",
        "'내일이 없다'고\n말한 곤충은?\n하루살이",
        "개가 한쪽 다리 들고\n오줌 누는 이유?\n넘어지지\n않으려고",
        "깨끗한 친구\n사귀려면?\n목욕탕",
        "낭떠러지에 매달린\n사람이 싸는 똥은?\n떨어질똥 말똥\n죽을똥 쌀똥",
        "전쟁 중 장군이\n받고 싶은 복은?\n항복",
        "하늘엔 총 둘,\n땅엔 침 둘?\n별총총 어두침침",
        "해에게 오빠가\n있다면?\n해오라비",
        "해의 성별은?\n여자\n(오빠가 있으니까)",
        "피할 건 피하고\n알릴 건 알리고?\nPR",
        "인정도 눈물도\n없는 아버지?\n허수아비",
        "도 통한 스님이\n많은 절은?\n통도사",
        "개구리가 낙지를\n먹으면?\n개구락지",
        "방자의 향단이\n사랑을 3자로?\n방향성",
        "'네 코는 어려 보여'\n를 영어로?\n니코틴",
        "제일 비싼 닭?\n코스닥",
        "단번에 죽는 닭?\n꼴까닭",
        "정신 줄 놓는 닭?\n헷가닥",
        "가장 섹시한 닭?\n홀딱",
        "집안 망치는 닭?\n쫄딱",
        "시골 사는 닭?\n촌딱",
        "가장 날씬한 닭?\n한가닥",
        "가장 흥분 잘하는 닭?\n팔딱팔딱",
        "가장 천한 닭?\n밑바닥",
        "최고의 닭은?\n토닥토닥",
        "싱싱한 닭?\n파닥파닥",
        "심장 두근대는 닭?\n콩닭콩닭",
        "임금님의 성은?\n납\n(상감마마 납시오)",
        "불쌍한 사람들이\n타는 차?\n기아자동차",
        "살면서 피해야 할\n개 두 마리?\n편견과 선입견",
        "안개는 왜\n안개일까?\n안 게니까",
        "김밥 vs 햄버거\n달리기 승자는?\n햄버거\n(패스트푸드)",
        "전원이 나갔을 땐?\n전원 집합!",
        // Commit-themed bonus lines.
        "커밋 완료!\n오늘도 잔디\n심었네 🌱",
        "푸시까지 했어?\n역시 너야 너 🚀",
    ]

    /// A random joke. `avoid` lets the caller skip the previous one so the same
    /// joke doesn't show twice in a row.
    static func random(avoiding avoid: String? = nil) -> String {
        let pool = lines.count > 1 ? lines.filter { $0 != avoid } : lines
        let source = pool.isEmpty ? lines : pool
        return source[Int.random(in: 0..<source.count)]
    }
}
