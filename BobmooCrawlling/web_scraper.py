import asyncio
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup
import logging
import requests
import PyPDF2
import io
import os
import tempfile
from urllib.parse import urljoin, urlparse

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
                    user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                    ignore_https_errors=True
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
    
    def detect_pdf_links(self, html_content: str, base_url: str) -> list:
        """
        HTML에서 PDF 링크를 찾습니다.
        
        Args:
            html_content (str): HTML 내용
            base_url (str): 기본 URL
            
        Returns:
            list: PDF 링크 리스트
        """
        try:
            soup = BeautifulSoup(html_content, 'html.parser')
            pdf_links = []
            
            # PDF 링크 찾기
            for link in soup.find_all('a', href=True):
                href = link['href']
                # 상대 URL을 절대 URL로 변환
                full_url = urljoin(base_url, href)
                
                # PDF 파일인지 확인
                if href.lower().endswith('.pdf') or 'pdf' in link.get_text().lower():
                    pdf_links.append(full_url)
                    self.logger.info(f"PDF 링크 발견: {full_url}")
            
            # iframe이나 embed 태그에서도 PDF 찾기
            for iframe in soup.find_all(['iframe', 'embed']):
                src = iframe.get('src')
                if src and (src.lower().endswith('.pdf') or 'pdf' in src.lower()):
                    full_url = urljoin(base_url, src)
                    pdf_links.append(full_url)
                    self.logger.info(f"PDF iframe/embed 발견: {full_url}")
            
            return pdf_links
            
        except Exception as e:
            self.logger.error(f"PDF 링크 감지 중 오류 발생: {str(e)}")
            return []
    
    def download_pdf(self, pdf_url: str) -> bytes:
        """
        PDF 파일을 다운로드합니다.
        
        Args:
            pdf_url (str): PDF URL
            
        Returns:
            bytes: PDF 파일 내용
        """
        try:
            self.logger.info(f"PDF 다운로드 시작: {pdf_url}")
            
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            
            response = requests.get(pdf_url, headers=headers, timeout=30)
            response.raise_for_status()
            
            self.logger.info(f"PDF 다운로드 완료: {len(response.content)} bytes")
            return response.content
            
        except Exception as e:
            self.logger.error(f"PDF 다운로드 중 오류 발생: {str(e)}")
            raise
    
    def extract_text_from_pdf(self, pdf_content: bytes) -> str:
        """
        PDF에서 텍스트를 추출합니다.
        
        Args:
            pdf_content (bytes): PDF 파일 내용
            
        Returns:
            str: 추출된 텍스트
        """
        try:
            self.logger.info("PDF 텍스트 추출 시작")
            
            # PDF 파일을 메모리에서 읽기
            pdf_file = io.BytesIO(pdf_content)
            pdf_reader = PyPDF2.PdfReader(pdf_file)
            
            text = ""
            for page_num in range(len(pdf_reader.pages)):
                page = pdf_reader.pages[page_num]
                text += page.extract_text() + "\n"
            
            # 텍스트 정리
            lines = (line.strip() for line in text.splitlines())
            chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
            clean_text = ' '.join(chunk for chunk in chunks if chunk)
            
            self.logger.info(f"PDF 텍스트 추출 완료: {len(clean_text)} 문자")
            return clean_text
            
        except Exception as e:
            self.logger.error(f"PDF 텍스트 추출 중 오류 발생: {str(e)}")
            raise
    
    async def scrape_content(self, url: str, wait_time: int = 3000) -> tuple[str, bool]:
        """
        URL에서 HTML 또는 PDF 내용을 가져옵니다.
        PDF가 감지되면 PDF를 다운로드하고 텍스트를 추출합니다.
        
        Args:
            url (str): 스크래핑할 URL
            wait_time (int): 페이지 로딩 대기 시간 (밀리초)
            
        Returns:
            tuple[str, bool]: (추출된 텍스트, PDF 여부)
        """
        try:
            # 먼저 HTML을 가져와서 PDF 링크가 있는지 확인
            html_content = await self.scrape_html(url, wait_time)
            soup = BeautifulSoup(html_content, 'html.parser')
            
            # PDF 링크 감지
            pdf_links = self.detect_pdf_links(html_content, url)
            
            if pdf_links:
                self.logger.info(f"PDF 링크 {len(pdf_links)}개 발견, PDF 처리 시작")
                
                # 첫 번째 PDF 링크 사용 (여러 개가 있으면 첫 번째만)
                pdf_url = pdf_links[0]
                
                # PDF 다운로드 및 텍스트 추출
                pdf_content = self.download_pdf(pdf_url)
                pdf_text = self.extract_text_from_pdf(pdf_content)
                
                return pdf_text, True  # PDF 처리됨
            else:
                # PDF가 없으면 기존 HTML 처리
                self.logger.info("PDF 링크가 없음, HTML 처리")
                return self.clean_html(html_content), False  # HTML 처리됨
                
        except Exception as e:
            self.logger.error(f"콘텐츠 스크래핑 중 오류 발생: {str(e)}")
            raise
 