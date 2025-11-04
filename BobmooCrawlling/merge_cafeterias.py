#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
from datetime import datetime

def merge_cafeterias():
    """2025년 파일들에 기존 식당 정보를 추가합니다."""
    
    output_dir = "output"
    
    # 2024년 파일에서 기본 식당 정보 추출
    base_file = "Inha_University_2024-09-29.json"
    base_path = os.path.join(output_dir, base_file)
    
    if not os.path.exists(base_path):
        print(f"❌ 기본 파일을 찾을 수 없습니다: {base_file}")
        return
    
    # 기본 식당 정보 로드
    with open(base_path, 'r', encoding='utf-8') as f:
        base_data = json.load(f)
    
    # 기본 식당들 (생활관 제외)
    base_cafeterias = []
    for cafeteria in base_data['cafeterias']:
        if '생활관' not in cafeteria['name']:
            base_cafeterias.append(cafeteria)
    
    print(f"📋 기본 식당 정보 ({len(base_cafeterias)}개):")
    for cafeteria in base_cafeterias:
        print(f"  - {cafeteria['name']}")
    
    # 2025년 파일들 처리
    updated_files = 0
    
    for filename in os.listdir(output_dir):
        if filename.startswith('Inha_University_2025-') and filename.endswith('.json'):
            filepath = os.path.join(output_dir, filename)
            
            print(f"\n📝 처리 중: {filename}")
            
            # 2025년 파일 로드
            with open(filepath, 'r', encoding='utf-8') as f:
                data_2025 = json.load(f)
            
            # 현재 식당들 확인
            current_cafeterias = [caf['name'] for caf in data_2025['cafeterias']]
            print(f"  현재 식당: {current_cafeterias}")
            
            # 기본 식당들 추가 (중복 제외)
            for base_cafeteria in base_cafeterias:
                if base_cafeteria['name'] not in current_cafeterias:
                    data_2025['cafeterias'].append(base_cafeteria)
                    print(f"  ✅ 추가: {base_cafeteria['name']}")
                else:
                    print(f"  ⏭️ 이미 존재: {base_cafeteria['name']}")
            
            # 파일 저장
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data_2025, f, ensure_ascii=False, indent=4)
            
            print(f"  💾 저장 완료: {len(data_2025['cafeterias'])}개 식당")
            updated_files += 1
    
    print(f"\n🎉 통합 완료!")
    print(f"  - 업데이트된 파일: {updated_files}개")

def main():
    print("🏫 식당 정보 통합 시작...")
    merge_cafeterias()
    
    # 결과 확인
    print(f"\n📂 2025년 파일들 확인:")
    output_dir = "output"
    files_2025 = [f for f in os.listdir(output_dir) if f.startswith('Inha_University_2025-') and f.endswith('.json')]
    files_2025.sort()
    
    for filename in files_2025:
        filepath = os.path.join(output_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        cafeteria_names = [caf['name'] for caf in data['cafeterias']]
        print(f"  - {filename}: {cafeteria_names}")

if __name__ == "__main__":
    main()
