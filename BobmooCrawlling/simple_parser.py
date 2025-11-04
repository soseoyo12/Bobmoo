#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
from datetime import datetime, timedelta

def create_dormitory_menus():
    """생활관 메뉴 JSON 생성"""
    
    # 9월 29일부터 10월 5일까지 7일간
    start_date = datetime(2025, 9, 29)
    menus = []
    
    for i in range(7):
        date = (start_date + timedelta(days=i)).strftime('%Y-%m-%d')
        is_weekend = i >= 5  # 토요일, 일요일
        
        menu = {
            "date": date,
            "school": "인하대학교 생활관",
            "cafeterias": [
                {
                    "name": "생활관 식당",
                    "hours": {
                        "breakfast": "07:30-09:00",
                        "lunch": "11:30-13:30",
                        "dinner": "17:30-19:30"
                    },
                    "meals": {}
                }
            ]
        }
        
        # 평일 아침 메뉴
        if not is_weekend:
            menu["cafeterias"][0]["meals"]["breakfast"] = [
                {
                    "course": "A",
                    "mainMenu": "모닝브래드2종*잼, 스크램블에그, 계절과일",
                    "price": 3000
                }
            ]
        
        # 점심 메뉴
        if not is_weekend:
            menu["cafeterias"][0]["meals"]["lunch"] = [
                {
                    "course": "A",
                    "mainMenu": "쌀밥, 돈육떡볶음, 얼갈이된장국, 배추김치",
                    "price": 4500
                },
                {
                    "course": "B", 
                    "mainMenu": "잡곡밥, 불고기야채비빔밥, 유부장국, 깍두기",
                    "price": 4500
                }
            ]
        else:
            # 주말 점심
            menu["cafeterias"][0]["meals"]["lunch"] = [
                {
                    "course": "A",
                    "mainMenu": "샌드위치&음료, 시리얼*우유",
                    "price": 4000
                }
            ]
        
        # 평일 저녁 메뉴
        if not is_weekend:
            menu["cafeterias"][0]["meals"]["dinner"] = [
                {
                    "course": "A",
                    "mainMenu": "쌀밥, 오징어까스하이라이스, 미역국, 배추김치",
                    "price": 5000
                }
            ]
        
        menus.append(menu)
    
    return menus

def main():
    print("🍽️ 생활관 메뉴 생성 시작...")
    
    menus = create_dormitory_menus()
    
    print(f"✅ {len(menus)}일간의 메뉴 생성 완료!")
    
    # 각 날짜별로 JSON 파일 저장
    for menu in menus:
        date = menu['date']
        filename = f"output/인하대학교_생활관_{date}.json"
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(menu, f, ensure_ascii=False, indent=4)
        
        print(f"📁 저장됨: {filename}")
    
    # 첫 번째 메뉴 미리보기
    print(f"\n📋 첫 번째 메뉴 미리보기 ({menus[0]['date']}):")
    print(json.dumps(menus[0], ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
