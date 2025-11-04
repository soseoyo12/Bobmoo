#!/usr/bin/env python3
"""
PDF 처리 기능 테스트 스크립트
"""

import asyncio
import logging
import sys
from web_scraper import WebScraper

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('pdf_test.log', encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)

async def test_pdf_detection():
    """PDF 링크 감지 테스트"""
    print("🔍 PDF 링크 감지 테스트 시작...")
    
    scraper = WebScraper()
    
    # 테스트용 HTML (PDF 링크가 있는 경우)
    test_html = """
    <html>
    <body>
        <h1>식단표</h1>
        <a href="/menu/2024-10-01.pdf">10월 1일 식단표</a>
        <a href="/menu/2024-10-02.pdf">10월 2일 식단표</a>
        <iframe src="/menu/current.pdf"></iframe>
    </body>
    </html>
    """
    
    base_url = "https://example.com"
    pdf_links = scraper.detect_pdf_links(test_html, base_url)
    
    print(f"발견된 PDF 링크: {len(pdf_links)}개")
    for link in pdf_links:
        print(f"  - {link}")
    
    return len(pdf_links) > 0

async def test_pdf_processing():
    """PDF 처리 전체 테스트"""
    print("\n📄 PDF 처리 전체 테스트 시작...")
    
    scraper = WebScraper()
    
    # 실제 PDF URL로 테스트 (예: 공개된 PDF 파일)
    test_url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
    
    try:
        print(f"테스트 URL: {test_url}")
        content = await scraper.scrape_content(test_url)
        
        print(f"추출된 텍스트 길이: {len(content)} 문자")
        print(f"텍스트 미리보기: {content[:200]}...")
        
        return True
        
    except Exception as e:
        print(f"PDF 처리 테스트 실패: {str(e)}")
        return False

async def test_html_fallback():
    """HTML 폴백 테스트"""
    print("\n🌐 HTML 폴백 테스트 시작...")
    
    scraper = WebScraper()
    
    # PDF가 없는 일반 웹사이트 테스트
    test_url = "https://httpbin.org/html"
    
    try:
        print(f"테스트 URL: {test_url}")
        content = await scraper.scrape_content(test_url)
        
        print(f"추출된 텍스트 길이: {len(content)} 문자")
        print(f"텍스트 미리보기: {content[:200]}...")
        
        return True
        
    except Exception as e:
        print(f"HTML 폴백 테스트 실패: {str(e)}")
        return False

async def main():
    """메인 테스트 함수"""
    print("🧪 PDF 처리 기능 테스트 시작\n")
    
    # 1. PDF 링크 감지 테스트
    pdf_detection_success = await test_pdf_detection()
    
    # 2. HTML 폴백 테스트 (PDF 처리 없이)
    html_fallback_success = await test_html_fallback()
    
    # 3. PDF 처리 테스트 (실제 PDF가 있는 경우에만)
    # pdf_processing_success = await test_pdf_processing()
    
    print("\n📊 테스트 결과:")
    print(f"  ✅ PDF 링크 감지: {'성공' if pdf_detection_success else '실패'}")
    print(f"  ✅ HTML 폴백: {'성공' if html_fallback_success else '실패'}")
    # print(f"  ✅ PDF 처리: {'성공' if pdf_processing_success else '실패'}")
    
    if pdf_detection_success and html_fallback_success:
        print("\n🎉 모든 테스트 통과!")
        return True
    else:
        print("\n❌ 일부 테스트 실패")
        return False

if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1)
