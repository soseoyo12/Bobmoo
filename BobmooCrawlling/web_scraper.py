import asyncio
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup
import logging

class WebScraper:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        
    async def scrape_html(self, url: str, wait_time: int = 3000) -> str:
        """
        지정된 URL에서 HTML을 가져옵니다.
        
        Args:
            url (str): 스크래핑할 URL
            wait_time (int): 페이지 로딩 대기 시간 (밀리초)
            
        Returns:
            str: HTML 문자열
        """
        try:
            async with async_playwright() as p:
                # 브라우저 실행 (Chrome 사용)
                browser = await p.chromium.launch(headless=True)
                context = await browser.new_context(
                    user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                )
                page = await context.new_page()
                
                # 페이지 로드
                self.logger.info(f"페이지 로딩 중: {url}")
                await page.goto(url, wait_until='networkidle')
                
                # 추가 대기 시간 (동적 콘텐츠 로딩을 위해)
                await page.wait_for_timeout(wait_time)
                
                # HTML 가져오기
                html_content = await page.content()
                
                await browser.close()
                
                self.logger.info("HTML 스크래핑 완료")
                return html_content
                
        except Exception as e:
            self.logger.error(f"HTML 스크래핑 중 오류 발생: {str(e)}")
            raise
    
    def clean_html(self, html_content: str) -> str:
        """
        HTML을 정리하고 텍스트만 추출합니다.
        
        Args:
            html_content (str): 원본 HTML
            
        Returns:
            str: 정리된 텍스트
        """
        try:
            soup = BeautifulSoup(html_content, 'html.parser')
            
            # 스크립트와 스타일 태그 제거
            for script in soup(["script", "style"]):
                script.decompose()
            
            # 텍스트 추출
            text = soup.get_text()
            
            # 공백 정리
            lines = (line.strip() for line in text.splitlines())
            chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
            text = ' '.join(chunk for chunk in chunks if chunk)
            
            return text
            
        except Exception as e:
            self.logger.error(f"HTML 정리 중 오류 발생: {str(e)}")
            raise
