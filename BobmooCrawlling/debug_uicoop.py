#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import asyncio
import logging
import sys
from web_scraper import WebScraper

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

async def debug_uicoop():
    """UICoop 사이트 디버깅"""
    print("🔍 UICoop 사이트 디버깅 시작...")
    
    scraper = WebScraper()
    url = "https://www.uicoop.ac.kr/main.php?mkey=2&w=2"
    
    try:
        # HTML 텍스트 추출
        text, is_pdf = await scraper.scrape_content(url)
        
        print(f"\n📄 스크래핑 결과:")
        print(f"  - PDF 여부: {is_pdf}")
        print(f"  - 텍스트 길이: {len(text)} 문자")
        print(f"\n📋 추출된 텍스트 내용:")
        print("=" * 80)
        print(text)
        print("=" * 80)
        
        # 식단 관련 키워드 검색
        menu_keywords = ['아침', '점심', '저녁', '식단', '메뉴', '밥', '국', '반찬', '식당', '카페테리아']
        print(f"\n🍽️ 식단 관련 키워드 검색:")
        found_keywords = []
        for keyword in menu_keywords:
            if keyword in text:
                found_keywords.append(keyword)
                print(f"  - '{keyword}' 발견")
        
        if not found_keywords:
            print("  - 식단 관련 키워드를 찾을 수 없습니다.")
        
        return text
        
    except Exception as e:
        print(f"❌ 오류 발생: {str(e)}")
        return None

if __name__ == "__main__":
    asyncio.run(debug_uicoop())
