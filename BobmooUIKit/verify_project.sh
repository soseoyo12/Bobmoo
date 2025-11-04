#!/bin/bash

# BobmooUIKit 프로젝트 검증 스크립트
# 모든 필요한 파일이 올바른 위치에 있는지 확인합니다.

echo "🔍 BobmooUIKit 프로젝트 검증 시작..."
echo ""

PROJECT_DIR="BobmooUIKit"
ERRORS=0
WARNINGS=0

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 파일 존재 확인 함수
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (파일 없음)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# 디렉토리 존재 확인 함수
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ (디렉토리 없음)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Swift 소스 파일 확인
echo -e "${BLUE}📝 Swift 소스 파일 확인${NC}"
check_file "$PROJECT_DIR/AppDelegate.swift"
check_file "$PROJECT_DIR/SceneDelegate.swift"
check_file "$PROJECT_DIR/AppGroup.swift"
check_file "$PROJECT_DIR/Models.swift"
check_file "$PROJECT_DIR/NetworkService.swift"
check_file "$PROJECT_DIR/MainViewController.swift"
check_file "$PROJECT_DIR/SettingsViewController.swift"
check_file "$PROJECT_DIR/UIColor+Extensions.swift"
check_file "$PROJECT_DIR/UIFont+Extensions.swift"
echo ""

# 리소스 파일 확인
echo -e "${BLUE}🎨 리소스 파일 확인${NC}"
check_file "$PROJECT_DIR/Info.plist"
check_dir "$PROJECT_DIR/Assets.xcassets"
check_dir "$PROJECT_DIR/fonts"
check_dir "$PROJECT_DIR/Base.lproj"
echo ""

# 폰트 파일 확인
echo -e "${BLUE}🔤 Pretendard 폰트 파일 확인${NC}"
FONT_DIR="$PROJECT_DIR/fonts"
FONT_FILES=(
    "Pretendard-Thin.ttf"
    "Pretendard-ExtraLight.ttf"
    "Pretendard-Light.ttf"
    "Pretendard-Regular.ttf"
    "Pretendard-Medium.ttf"
    "Pretendard-SemiBold.ttf"
    "Pretendard-Bold.ttf"
    "Pretendard-ExtraBold.ttf"
    "Pretendard-Black.ttf"
)

for font in "${FONT_FILES[@]}"; do
    check_file "$FONT_DIR/$font"
done
echo ""

# Assets 확인
echo -e "${BLUE}🖼️ Assets 확인${NC}"
check_dir "$PROJECT_DIR/Assets.xcassets/pastelBlue.colorset"
check_dir "$PROJECT_DIR/Assets.xcassets/pastelBlue_real.colorset"
check_dir "$PROJECT_DIR/Assets.xcassets/BobmooLogo.imageset"
check_dir "$PROJECT_DIR/Assets.xcassets/AppIcon.appiconset"
echo ""

# Info.plist에서 폰트 등록 확인
echo -e "${BLUE}📋 Info.plist 설정 확인${NC}"
if [ -f "$PROJECT_DIR/Info.plist" ]; then
    if grep -q "UIAppFonts" "$PROJECT_DIR/Info.plist"; then
        echo -e "${GREEN}✓${NC} UIAppFonts 키 존재"
        
        # 등록된 폰트 개수 확인
        FONT_COUNT=$(grep -c "Pretendard-" "$PROJECT_DIR/Info.plist" || echo "0")
        if [ "$FONT_COUNT" -ge "9" ]; then
            echo -e "${GREEN}✓${NC} 폰트 $FONT_COUNT개 등록됨"
        else
            echo -e "${YELLOW}⚠${NC} 폰트 $FONT_COUNT개만 등록됨 (9개 필요)"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo -e "${RED}✗${NC} UIAppFonts 키 없음"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Storyboard 제거 확인
    if grep -q "UISceneStoryboardFile" "$PROJECT_DIR/Info.plist"; then
        echo -e "${YELLOW}⚠${NC} UISceneStoryboardFile 키 존재 (제거 권장)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓${NC} UISceneStoryboardFile 키 없음 (프로그래매틱 UI)"
    fi
else
    echo -e "${RED}✗${NC} Info.plist 파일 없음"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 불필요한 파일 확인
echo -e "${BLUE}🗑️ 불필요한 파일 확인${NC}"
if [ -f "$PROJECT_DIR/ViewController.swift" ]; then
    echo -e "${YELLOW}⚠${NC} ViewController.swift 존재 (삭제 권장)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} ViewController.swift 없음"
fi

if [ -f "$PROJECT_DIR/Base.lproj/Main.storyboard" ]; then
    echo -e "${YELLOW}⚠${NC} Main.storyboard 존재 (삭제 권장)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} Main.storyboard 없음"
fi
echo ""

# 문서 파일 확인
echo -e "${BLUE}📖 문서 파일 확인${NC}"
check_file "README.md"
check_file "QUICK_START.md"
check_file "BUILD_GUIDE.md"
check_file "MIGRATION_SUMMARY.md"
echo ""

# Swift 파일 라인 수 통계
echo -e "${BLUE}📊 코드 통계${NC}"
if command -v wc &> /dev/null; then
    TOTAL_LINES=$(find "$PROJECT_DIR" -name "*.swift" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
    SWIFT_FILES=$(find "$PROJECT_DIR" -name "*.swift" -type f | wc -l | tr -d ' ')
    echo "Swift 파일: $SWIFT_FILES개"
    echo "총 코드 라인: $TOTAL_LINES줄"
fi
echo ""

# 결과 출력
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ 모든 검증 통과!${NC}"
    echo "프로젝트가 빌드 준비 완료되었습니다."
    echo ""
    echo "다음 명령으로 Xcode에서 프로젝트를 열 수 있습니다:"
    echo "  open BobmooUIKit/BobmooUIKit.xcodeproj"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️ 검증 완료 (경고 ${WARNINGS}개)${NC}"
    echo "프로젝트는 빌드 가능하지만 일부 개선사항이 있습니다."
    exit 0
else
    echo -e "${RED}❌ 검증 실패 (오류 ${ERRORS}개, 경고 ${WARNINGS}개)${NC}"
    echo "위의 오류를 수정한 후 다시 시도하세요."
    exit 1
fi
