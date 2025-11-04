#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
import shutil
from datetime import datetime

def merge_inha_files():
    """인하대학교 관련 파일들을 통합합니다."""
    
    output_dir = "output"
    
    # 기존 인하대학교 파일들 찾기
    inha_files = []
    dorm_files = []
    
    for filename in os.listdir(output_dir):
        if filename.endswith('.json'):
            if filename.startswith('Inha_University_'):
                inha_files.append(filename)
            elif filename.startswith('인하대학교_생활관_'):
                dorm_files.append(filename)
    
    print(f"🔍 발견된 파일들:")
    print(f"  - 기존 인하대학교 파일: {len(inha_files)}개")
    print(f"  - 생활관 파일: {len(dorm_files)}개")
    
    # 생활관 파일들을 인하대학교 형식으로 변환
    for dorm_file in dorm_files:
        print(f"\n📝 처리 중: {dorm_file}")
        
        # 파일 읽기
        with open(os.path.join(output_dir, dorm_file), 'r', encoding='utf-8') as f:
            dorm_data = json.load(f)
        
        # 학교명을 "인하대학교"로 변경
        dorm_data['school'] = "인하대학교"
        
        # 생활관 식당명을 더 명확하게 변경
        for cafeteria in dorm_data['cafeterias']:
            if cafeteria['name'] == '생활관 식당':
                cafeteria['name'] = '생활관 식당(기숙사)'
        
        # 새로운 파일명 생성 (Inha_University_ 형식)
        date_str = dorm_data['date']
        new_filename = f"Inha_University_{date_str}.json"
        
        # 파일 저장
        with open(os.path.join(output_dir, new_filename), 'w', encoding='utf-8') as f:
            json.dump(dorm_data, f, ensure_ascii=False, indent=4)
        
        print(f"  ✅ 변환 완료: {new_filename}")
        
        # 기존 생활관 파일 삭제
        os.remove(os.path.join(output_dir, dorm_file))
        print(f"  🗑️ 기존 파일 삭제: {dorm_file}")
    
    print(f"\n🎉 통합 완료!")
    print(f"  - 변환된 파일: {len(dorm_files)}개")
    print(f"  - 총 인하대학교 파일: {len(inha_files) + len(dorm_files)}개")

def main():
    print("🏫 인하대학교 파일 통합 시작...")
    merge_inha_files()
    
    # 결과 확인
    print(f"\n📂 최종 파일 목록:")
    output_dir = "output"
    inha_files = [f for f in os.listdir(output_dir) if f.startswith('Inha_University_') and f.endswith('.json')]
    inha_files.sort()
    
    for filename in inha_files:
        print(f"  - {filename}")

if __name__ == "__main__":
    main()
