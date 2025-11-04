#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
import shutil
from datetime import datetime

def fix_dates_and_merge():
    """2024년 파일들을 2025년으로 수정하고 통합합니다."""
    
    output_dir = "output"
    
    # 2024년 파일들 찾기
    files_2024 = [f for f in os.listdir(output_dir) if f.startswith('Inha_University_2024-') and f.endswith('.json')]
    files_2024.sort()
    
    print(f"🔍 발견된 2024년 파일들: {len(files_2024)}개")
    for f in files_2024:
        print(f"  - {f}")
    
    # 2024년 파일들을 2025년으로 변환
    converted_files = []
    
    for filename in files_2024:
        print(f"\n📝 처리 중: {filename}")
        
        # 파일 읽기
        filepath = os.path.join(output_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 날짜를 2025년으로 변경
        old_date = data['date']
        new_date = old_date.replace('2024', '2025')
        data['date'] = new_date
        
        # 새로운 파일명 생성
        new_filename = filename.replace('2024', '2025')
        new_filepath = os.path.join(output_dir, new_filename)
        
        # 기존 2025년 파일이 있는지 확인
        if os.path.exists(new_filepath):
            print(f"  ⚠️ 기존 2025년 파일 존재: {new_filename}")
            
            # 기존 2025년 파일 읽기
            with open(new_filepath, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
            
            # 식당 정보 병합
            existing_cafeterias = [caf['name'] for caf in existing_data['cafeterias']]
            
            for cafeteria in data['cafeterias']:
                if cafeteria['name'] not in existing_cafeterias:
                    existing_data['cafeterias'].append(cafeteria)
                    print(f"    ✅ 추가: {cafeteria['name']}")
                else:
                    print(f"    ⏭️ 이미 존재: {cafeteria['name']}")
            
            # 통합된 데이터 저장
            with open(new_filepath, 'w', encoding='utf-8') as f:
                json.dump(existing_data, f, ensure_ascii=False, indent=4)
            
            print(f"    💾 통합 완료: {len(existing_data['cafeterias'])}개 식당")
            
        else:
            # 새로운 2025년 파일로 저장
            with open(new_filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=4)
            print(f"  ✅ 새 파일 생성: {new_filename}")
        
        # 기존 2024년 파일 삭제
        os.remove(filepath)
        print(f"  🗑️ 기존 파일 삭제: {filename}")
        
        converted_files.append(new_filename)
    
    print(f"\n🎉 날짜 수정 및 통합 완료!")
    print(f"  - 변환된 파일: {len(converted_files)}개")
    
    # 최종 결과 확인
    print(f"\n📂 최종 2025년 파일 목록:")
    files_2025 = [f for f in os.listdir(output_dir) if f.startswith('Inha_University_2025-') and f.endswith('.json')]
    files_2025.sort()
    
    for filename in files_2025:
        filepath = os.path.join(output_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        cafeteria_names = [caf['name'] for caf in data['cafeterias']]
        print(f"  - {filename}: {len(cafeteria_names)}개 식당 - {cafeteria_names}")

def main():
    print("📅 날짜 수정 및 통합 시작...")
    fix_dates_and_merge()

if __name__ == "__main__":
    main()
