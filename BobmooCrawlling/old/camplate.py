import requests
from bs4 import BeautifulSoup #정적 페이지 크롤링을 위한 모듈
import base64 #링크 해독
from urllib.parse import quote, unquote #링크해독 2
from datetime import datetime, timedelta, date #시간 계산, 요일 확인
import time #현재 시간 불러오기
from fake_useragent import UserAgent #useragent 모듈

#universityMeal_Url_origin = "fnct1|@@|/diet/kr/2/view.do?monday=2025.06.30&week=next&" 

"""
today = date.today() #오늘의 날짜 불러오기
next_day = today + timedelta(days=7) #7일 후 날짜 계산
formatted_day = next_day.strftime("%Y.%m.%d") #2025.07.04 형태로 출력


before_link_str = "fnct1|@@|/diet/kr/2/view.do?monday="+formatted_day+"&week=next&"
before_link_bytes = before_link_str.encode('UTF-8') #문자열 url을 byte형태로 바꾸기
## encoded_data = quote(before_link_bytes, safe='') #퍼센트 인코딩 
## result_link = base64.b64encode(encoded_data) #base64 인코딩
result_link = base64.b64encode(before_link_bytes) #base64 인코딩
encoded_data = quote(result_link, safe='') #퍼센트 인코딩 


data = [] #db에 넣기전 리스트 선언
url = "https://www.inha.ac.kr/kr/1072/subview.do?&enc=" + encoded_data #최종 주소 결합
"""


user_agent = UserAgent()
headers = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
    'Cache-Control': 'max-age=0',
    'Connection': 'keep-alive',
    'Referer': 'https://www.google.com/', # Referer 헤더는 때로 중요하게 작용합니다.
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'cross-site',
    'Sec-Fetch-User': '?1',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
    'sec-ch-ua': '"Not)A;Brand";v="8", "Chromium";v="138", "Google Chrome";v="138"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"macOS"',
}

cookies = {
    '_ga_EMBK5DZ5XK': 'GS1.1.1744729103.4.0.1744729103.0.0.0',
    '_ga_E323M45YWM': 'GS2.1.s1750660760$o54$g1$t1750660760$j60$l0$h0',
    'JSESSIONID': '9CBDAA2A5AD43F2794E9C749E3123E60', # 세션 유지를 위한 중요한 쿠키일 수 있습니다.
    '_gid': 'GA1.3.807129918.1751207425',
    '_gat_gtag_UA_78301200_19': '1',
    '_ga_VZWY81VB3W': 'GS2.1.s1751207424$o1$g0$t1751207424$j60$l0$h0',
    '_ga': 'GA1.1.2113335301.1744544466',
}


response = requests.get("https://www.inha.ac.kr/kr/1072/subview.do", headers=headers) 
html = response.text


soup = BeautifulSoup(html, 'html.parser')

# HTML 구조를 확인하기 위해 파일로 저장
with open('debug.html', 'w', encoding='utf-8') as f:
    f.write(html)

items = soup.select('.table_1.no_mTable')
print(f"찾은 테이블 개수: {len(items)}")

for i, item in enumerate(items, 1):
    print(f"\n=== 테이블 {i} ===")
    
    # 각 테이블의 모든 행을 찾기
    rows = item.select('tbody tr')
    
    for row in rows:
        # 각 행에서 요소들을 찾기
        restaurant_elem = row.select_one('th[scope="row"]')
        food_elem = row.select_one('td.left')
        price_elem = row.select_one('td:last-child')  # 마지막 td (가격)
        
        if restaurant_elem and food_elem and price_elem:
            restaurant = restaurant_elem.text.strip()
            food = food_elem.text.strip()
            price = price_elem.text.strip()
            print(f"식당: {restaurant}, 음식: {food}, 가격: {price}")
        else:
            print("이 행에서 요소를 찾을 수 없습니다.")
            # 디버깅 정보
            if restaurant_elem:
                print(f"  식당: {restaurant_elem.text.strip()}")
            if food_elem:
                print(f"  음식: {food_elem.text.strip()}")
            if price_elem:
                print(f"  가격: {price_elem.text.strip()}")


