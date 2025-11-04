#!/usr/bin/env python3
"""
PDF 텍스트 추출 디버깅 스크립트
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
        logging.StreamHandler(sys.stdout)
    ]
)

async def debug_pdf_extraction():
    """PDF 텍스트 추출 디버깅"""
    print("🔍 PDF 텍스트 추출 디버깅 시작...")
    
    scraper = WebScraper()
    url = "https://dorm.inha.ac.kr/dorm/10136/subview.do?enc=Zm5jdDF8QEB8JTJGYmJzJTJGZG9ybSUyRjI1MzMlMkYxNjI3ODElMkZhcnRjbFZpZXcuZG8lM0ZwYWdlJTNEMSUyNnNyY2hDb2x1bW4lM0QlMjZzcmNoV3JkJTNEJTI2YmJzQ2xTZXElM0QlMjZiYnNPcGVuV3JkU2VxJTNEJTI2cmdzQmduZGVTdHIlM0QlMjZyZ3NFbmRkZVN0ciUzRCUyNmlzVmlld01pbmUlM0RmYWxzZSUyNnBhc3N3b3JkJTNEJTI2"
    
    try:
        # PDF 텍스트 추출
        text, is_pdf = await scraper.scrape_content(url)
        
        print(f"\n📄 PDF 텍스트 추출 결과:")
        print(f"  - PDF 여부: {is_pdf}")
        print(f"  - 텍스트 길이: {len(text)} 문자")
        print(f"\n📋 추출된 텍스트 내용:")
        print("=" * 80)
        print(text)
        print("=" * 80)
        
        # 텍스트에서 날짜 정보 찾기
        import re
        date_patterns = [
            r'2025\.?\s*09\.?\s*29',
            r'2025\.?\s*09\.?\s*30', 
            r'2025\.?\s*10\.?\s*0[1-5]',
            r'9월\s*29일',
            r'9월\s*30일',
            r'10월\s*[1-5]일'
        ]
        
        print(f"\n🔍 날짜 정보 검색:")
        for pattern in date_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            if matches:
                print(f"  - {pattern}: {matches}")
        
        # 식단 관련 키워드 검색
        menu_keywords = ['아침', '점심', '저녁', '식단', '메뉴', '밥', '국', '반찬']
        print(f"\n🍽️ 식단 관련 키워드 검색:")
        for keyword in menu_keywords:
            if keyword in text:
                print(f"  - '{keyword}' 발견")
        
        return text
        
    except Exception as e:
        print(f"❌ 오류 발생: {str(e)}")
        return None

if __name__ == "__main__":
    asyncio.run(debug_pdf_extraction())
