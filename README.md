# Gipet

## Support

**Need help? Contact us:**
- Email: sgolilla1@naver.com
- GitHub Issues: https://github.com/shinleehyeon/gipet/issues

**Frequently Asked Questions**

**Q: How do I sign in?**  
A: Click the menu bar icon → Sign in with GitHub. You can also paste a Personal Access Token (PAT) directly in the token field.

**Q: The dog went off screen — is that normal?**  
A: Yes! The dog occasionally wanders off-screen and comes back. It's intentional behavior.

**Q: My commit count shows 0 after refreshing.**  
A: This can happen due to GitHub's CDN cache. Wait a minute and refresh again.

**Q: How do I add a repository to watch?**  
A: Click the menu bar icon → "Add Folder" → select your git repository folder.

**Q: The app requires permission to access files. Why?**  
A: Gipet needs access to your git repositories to detect uncommitted changes and perform auto-commits.

For additional help, please open an issue on GitHub or send an email.

---

맥 메뉴바에서 돌아다니는 `Desktop Goose` 스타일 펫 앱입니다.  
거위/닥스훈트 캐릭터를 선택할 수 있고, 밈/노트 창을 물어오는 장난스러운 인터랙션을 제공합니다.

## 주요 기능

- 메뉴바 상주형 앱 (`LSUIElement`)
- 캐릭터 토글: `Goose` / `Dachshund`
- 행동 액션: `Honk`, `Nab Mouse`, `Wander`, `Heart Trail`, `Track Mud`
- 프로젝트 폴더의 밈/노트를 읽어와 창으로 표시
- `gipet://` URL 스킴 등록 (OAuth 콜백 연동 대비)

## 요구사항

- macOS 13+
- Swift 5.9+

## 빠른 실행 (개발용)

```bash
cd desktop-dog
swift run
```

## 앱 번들 패키징 (권장)

`Gipet.app`로 실행할 때는 아래 스크립트를 사용하세요.

```bash
cd desktop-dog
./package.sh --run
```

### 이 스크립트가 하는 일

- release 빌드
- `Gipet.app` 번들 생성
- ad-hoc codesign
- LaunchServices 등록 (`gipet://`)
- 기존 `Gipet` 프로세스 종료 후 `open -n`으로 새 인스턴스 실행

## 커스터마이징 포인트

- 밈 폴더: `desktop-dog/Memes`
- 노트 폴더: `desktop-dog/Notes`
- 캐릭터 렌더: `Sources/DesktopGoose/MacGoose/Characters`
- 메뉴 동작: `Sources/DesktopGoose/MacGoose/AppDelegate.swift`

## 자주 겪는 문제

### 코드 수정했는데 화면 반영이 안 됨

기존 앱 프로세스가 살아 있으면 `open Gipet.app`가 새 바이너리를 안 띄울 수 있습니다.  
`./package.sh --run`으로 재패키징 + 강제 재실행하세요.

## 프로젝트 구조

```text
desktop-dog/
├─ Sources/DesktopGoose/        # 앱 소스
├─ Memes/                       # 사용자 밈 이미지
├─ Notes/                       # 사용자 노트 텍스트
├─ package.sh                   # Gipet.app 번들 패키징 스크립트
└─ Package.swift
```
