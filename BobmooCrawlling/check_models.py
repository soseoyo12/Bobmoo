#!/usr/bin/env python3
"""
사용 가능한 Gemini 모델 목록을 확인하는 스크립트
"""

import google.generativeai as genai
from config import GEMINI_API_KEY

def check_available_models():
    """사용 가능한 모델 목록을 확인합니다."""
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        
        print("🔍 사용 가능한 모델 목록:")
        for model in genai.list_models():
            if 'generateContent' in model.supported_generation_methods:
                print(f"  - {model.name}")
                
    except Exception as e:
        print(f"❌ 모델 목록 조회 중 오류 발생: {e}")

if __name__ == "__main__":
    check_available_models()
