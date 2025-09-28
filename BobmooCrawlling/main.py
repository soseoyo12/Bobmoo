#!/usr/bin/env python3
"""
웹 스크래핑 및 Gemini API를 사용한 식당 메뉴 정보 추출 프로그램
"""

import asyncio
import logging
import argparse
import sys
from web_scraper import WebScraper
from gemini_parser import GeminiParser
from file_manager import FileManager

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scraper.log', encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)

class MenuScraper:
    def __init__(self, output_dir: str = "output"):
        self.web_scraper = WebScraper()
        self.gemini_parser = GeminiParser()
        self.file_manager = FileManager(output_dir)
        self.logger = logging.getLogger(__name__)
    
    async def scrape_and_save(self, urls: list, school_name: str = "인하대학교", wait_time: int = 3000):
        """
        여러 웹사이트를 스크래핑하고 JSON으로 저장합니다.
        
        Args:
            urls (list): 스크래핑할 URL 리스트
            school_name (str): 학교 이름
            wait_time (int): 페이지 로딩 대기 시간 (밀리초)
        """
        try:
            all_cafeteria_data = {}  # 날짜별로 모든 식당 정보를 저장
            
            # 각 URL에서 데이터 추출
            for i, url in enumerate(urls, 1):
                self.logger.info(f"스크래핑 시작 ({i}/{len(urls)}): {url}")
                
                # 1. HTML 스크래핑
                html_content = await self.web_scraper.scrape_html(url, wait_time)
                self.logger.info(f"HTML 스크래핑 완료 ({i}/{len(urls)})")
                
                # 2. HTML 정리
                clean_text = self.web_scraper.clean_html(html_content)
                self.logger.info(f"HTML 정리 완료 ({i}/{len(urls)})")
                
                # 3. Gemini API로 JSON 변환
                json_data_list = self.gemini_parser.parse_html_to_json(clean_text, school_name)
                self.logger.info(f"Gemini API 분석 완료 ({i}/{len(urls)}) - {len(json_data_list)}개 날짜의 데이터 추출")
                
                # 4. 날짜별로 식당 정보 병합
                for json_data in json_data_list:
                    date = json_data.get('date')
                    if date not in all_cafeteria_data:
                        all_cafeteria_data[date] = {
                            "date": date,
                            "school": school_name,
                            "cafeterias": []
                        }
                    
                    # 식당 정보 병합
                    merged_data = self.file_manager.merge_cafeteria_data(
                        all_cafeteria_data[date], 
                        json_data
                    )
                    all_cafeteria_data[date] = merged_data
            
            # 5. 각 날짜별로 JSON 파일 저장
            saved_files = []
            for date, json_data in all_cafeteria_data.items():
                filepath = self.file_manager.save_json_by_date(json_data, school_name)
                saved_files.append(filepath)
                self.logger.info(f"파일 저장 완료: {filepath}")
            
            return saved_files
            
        except Exception as e:
            self.logger.error(f"스크래핑 중 오류 발생: {str(e)}")
            raise

def main():
    parser = argparse.ArgumentParser(description='웹사이트에서 식당 메뉴 정보를 추출하여 JSON으로 저장합니다.')
    parser.add_argument('urls', nargs='+', help='스크래핑할 웹사이트 URL들 (여러 개 가능)')
    parser.add_argument('--school', '-s', default='인하대학교', help='학교 이름 (기본값: 인하대학교)')
    parser.add_argument('--output', '-o', default='output', help='출력 디렉토리 (기본값: output)')
    parser.add_argument('--wait', '-w', type=int, default=3000, help='페이지 로딩 대기 시간(밀리초) (기본값: 3000)')
    
    args = parser.parse_args()
    
    # MenuScraper 인스턴스 생성
    scraper = MenuScraper(args.output)
    
    # 비동기 실행
    try:
        saved_files = asyncio.run(scraper.scrape_and_save(args.urls, args.school, args.wait))
        print(f"\n✅ 성공적으로 완료되었습니다!")
        print(f"📁 저장된 파일 수: {len(saved_files)}개")
        
        # 저장된 파일 목록 출력
        print(f"\n📋 새로 생성된 파일 목록:")
        for file in saved_files:
            print(f"  - {file}")
        
        # 전체 저장된 파일 목록 출력
        all_files = scraper.file_manager.list_saved_files()
        if all_files:
            print(f"\n📂 전체 저장된 파일 목록:")
            for file in all_files:
                print(f"  - {file}")
                
    except KeyboardInterrupt:
        print("\n❌ 사용자에 의해 중단되었습니다.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 오류 발생: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
