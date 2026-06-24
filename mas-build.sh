#!/bin/bash
# MAS (Mac App Store) 배포용 빌드 스크립트
#
# 사전 준비:
#   1. ExportOptions.plist에서 YOUR_TEAM_ID와 프로비저닝 프로파일 이름 입력
#   2. project.yml에서 DEVELOPMENT_TEAM 입력 후 xcodegen generate 재실행
#   3. Apple Developer 계정에서 "Mac App Store" 프로비저닝 프로파일 생성
#   4. "Apple Distribution" 인증서가 키체인에 설치되어 있어야 함
#
# 사용법:
#   ./mas-build.sh                # 아카이브 + 앱스토어 업로드
#   ./mas-build.sh --archive-only # 아카이브만 (업로드 안 함)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE_PATH="$ROOT/build/Gipet.xcarchive"
EXPORT_PATH="$ROOT/build/export"
SCHEME="Gipet"
PROJECT="$ROOT/Gipet.xcodeproj"

mkdir -p "$ROOT/build"

echo "▸ xcodegen 프로젝트 갱신..."
xcodegen generate --spec "$ROOT/project.yml" --project "$ROOT"

echo "▸ 아카이브 빌드..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    ENABLE_HARDENED_RUNTIME=YES \
    | xcpretty 2>/dev/null || true

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "✗ 아카이브 실패: $ARCHIVE_PATH 없음"
    exit 1
fi
echo "✓ 아카이브 완료: $ARCHIVE_PATH"

if [ "${1:-}" = "--archive-only" ]; then
    echo "  --archive-only 플래그: 업로드 건너뜀"
    exit 0
fi

echo "▸ App Store 패키지 내보내기..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$ROOT/ExportOptions.plist" \
    | xcpretty 2>/dev/null || true

echo "✓ 완료"
echo ""
echo "  다음 단계:"
echo "  1. Xcode Organizer에서 $ARCHIVE_PATH 를 열어 App Store에 업로드"
echo "  2. 또는: xcrun altool --upload-package $EXPORT_PATH/Gipet.pkg \\"
echo "         --type macos --apple-id YOUR_APPLE_ID --password YOUR_APP_SPECIFIC_PASSWORD"
