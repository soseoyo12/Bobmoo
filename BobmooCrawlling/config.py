import os
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

# Gemini API 키 (직접 설정)
GEMINI_API_KEY = "AIzaSyB8Kclgeiw9SumgRPP4SIoXzTh3TMlMxTc"

# 환경변수에서 가져오기 시도 (우선순위)
env_key = os.getenv('GEMINI_API_KEY')
if env_key:
    GEMINI_API_KEY = env_key

if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY가 설정되지 않았습니다.")
