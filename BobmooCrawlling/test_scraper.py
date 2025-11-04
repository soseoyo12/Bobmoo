#!/usr/bin/env python3
"""
스크래퍼 테스트 스크립트
"""

import asyncio
import logging
from web_scraper import WebScraper
from gemini_parser import GeminiParser

# 로깅 설정
logging.basicConfig(level=logging.INFO)

async def test_scraper():
    """스크래퍼 기능을 테스트합니다."""
    
    # 테스트 URL (실제 식당 메뉴 사이트로 변경하세요)
    test_url = "https://example.com"
    
    try:
        print("🧪 스크래퍼 테스트 시작...")
        
        # 웹 스크래퍼 테스트
        scraper = WebScraper()
        print("📡 HTML 스크래핑 중...")
        html_content = await scraper.scrape_html(test_url, wait_time=2000)
        print(f"✅ HTML 스크래핑 완료 (길이: {len(html_content)} 문자)")
        
        # HTML 정리 테스트
        print("🧹 HTML 정리 중...")
        clean_text = scraper.clean_html(html_content)
        print(f"✅ HTML 정리 완료 (길이: {len(clean_text)} 문자)")
        
        # Gemini 파서 테스트 (API 키가 설정된 경우에만)
        try:
            parser = GeminiParser()
            print("🤖 Gemini API 분석 중...")
            json_data = parser.parse_html_to_json(clean_text[:1000])  # 테스트용으로 1000자만
            print("✅ Gemini API 분석 완료")
            print(f"📊 추출된 데이터: {json_data}")
        except Exception as e:
            print(f"⚠️ Gemini API 테스트 실패: {e}")
            print("💡 .env 파일에 GEMINI_API_KEY를 설정하세요.")
        
        print("🎉 테스트 완료!")
        
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")

if __name__ == "__main__":
    asyncio.run(test_scraper())
