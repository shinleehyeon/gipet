// Local addition — 아재개그 lines the dog says (via a speech bubble) when it
// detects you've committed today (or via the "말풍선 💬" menu item). Kept short
// and pre-wrapped with "\n" so the bubble never grows past the character view.

import Foundation

enum DadJokes {
    static let lines: [String] = [
        "신이 버스에서\n내리면?\n신내림",
        "돼지가 방귀 뀌면?\n돈가스",
        "아이가 아홉이면?\n아이구",
        "물고기의 반대말은?\n불고기",
        "우유가 우승하면?\n빙그레",
        "처음 만나는 소가\n하는 말은?\n반갑소",
        "소가 웃으면?\n우하하",
        "병아리가 잘 먹는\n약은?\n삐약",
        "개가 사람을\n가르치면?\n개인 지도",
        "돼지가 떨어지면?\n돈벼락",
        "전 재산을 부동산에\n투자한 부자가\n죽으면?\n저승사자",
        "비가 자기소개할 때\n하는 말은?\n나비야",
        "불장난으로 돈을\n벌면?\n불로소득",
        "세상에서 가장\n뜨거운 과일은?\n천도복숭아",
        "김밥이 죽으면?\n김밥천국",
        "돼지가 앉으면?\n돈방석",
        "자동차에 툭하고\n치면?\n카톡",
        "소나무가 빠지면?\n칫솔",
        "다리미가 좋아하는\n음식은?\n피자",
        "세상에서 가장\n지루한 중학교는?\n로딩 중",
        "광부가 가장 많은\n나라는?\n캐나(다)",
        "반성문을 영어로\n하면?\n글로벌",
        "정말 큰 학은?\n대학",
        "화학이 어려운\n이유는?\n케미스터리",
        "새우가 주인공인\n드라마는?\n대하드라마",
        "화장실에 사는\n두 마리 용은?\n신사용, 숙녀용",
        "높은 곳에서 아기를\n낳으면?\n하이에나",
        "아재가 좋아하는\n악기는?\n아쟁",
        "왕이 가면?\n바이킹",
        "스님이 가는\n내리막길은?\n불법 다운로드",
        "세 발 낙지가\n탈모 오면?\n한 발 낙지",
        "왕이 오른쪽에도\n왼쪽에도 있으면?\n우왕좌왕",
        "토끼가 강한 이유는?\n깡과 총이 있어서",
        "스님이 택시 타고\n한 말은?\n절로 가",
        "감기에 빨리\n걸리면?\n빨리 감기",
        "심마니에게 어디\n사냐고 물으면?\n산삼",
        "오래 살 것 같은\n연예인은?\n이승깁니다",
        "국내에 마블보다\n4배 큰 기업은?\n넷마블",
        "호주의 돈은?\n호주머니",
        "장사 제일 잘하는\n동물은?\n판다",
        "엄마들이 아침마다\n말하는 나라는?\n일어나라",
        "오리를 생으로\n먹으면?\n회오리",
        "'당신은 비를\n아십니까?'를\n네 글자로?\n너비아니",
        "몸무게가 가장\n많이 나갈 때?\n철들 때",
        "은행원이 파란색을\n좋아하는 이유?\n청약 해지가 싫어서",
        "세상에서 가장\n예쁜 식물은?\n뷰티플",
        "개들이 제일\n싫어하는 절은?\n보신각",
        "칼이 정색하면?\n검정색",
        "군인이 돈을\n다 쓰면?\n무전병",
        "포도가 자기소개하면?\n포도당",
        "야구 모자를\n때리면?\n야구 아빠가 달려옴",
        "아빠는 차 4대\n아들은 1대,\n4글자로?\n세대 차이",
        "겉으론 눈물,\n속은 타는 것은?\n촛불",
        "딸기가 회사에서\n잘리면?\n딸기시럽",
        "세상에서 가장\n큰 콩은?\n홍콩",
        "바바리맨이 축구를\n못하는 이유는?\n노골적이라서",
        "개랑 사람만\n사는 곳은?\n견인지역",
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
