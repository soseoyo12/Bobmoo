import json
import os
from datetime import datetime
from typing import Dict, Any
import logging

class FileManager:
    def __init__(self, output_dir: str = "output"):
        self.output_dir = output_dir
        self.logger = logging.getLogger(__name__)
        self._ensure_output_directory()
    
    def _ensure_output_directory(self):
        """출력 디렉토리가 존재하는지 확인하고 없으면 생성합니다."""
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
            self.logger.info(f"출력 디렉토리 생성: {self.output_dir}")
    
    def save_json_by_date(self, json_data: Dict[str, Any], school_name: str = None) -> str:
        """
        JSON 데이터를 날짜별로 파일에 저장합니다.
        
        Args:
            json_data (Dict[str, Any]): 저장할 JSON 데이터
            school_name (str): 학교 이름 (파일명에 포함)
            
        Returns:
            str: 저장된 파일 경로
        """
        try:
            # 날짜 추출
            date = json_data.get('date', datetime.now().strftime("%Y-%m-%d"))
            
            # 학교 이름 추출
            if not school_name:
                school_name = json_data.get('school', 'unknown')
            
            # 파일명 생성 (한글 제거하고 영문으로 변환)
            safe_school_name = self._sanitize_filename(school_name)
            
            # 인하대학교 관련은 모두 "Inha_University"로 통일
            if "인하대학교" in school_name:
                safe_school_name = "Inha_University"
            
            filename = f"{safe_school_name}_{date}.json"
            filepath = os.path.join(self.output_dir, filename)
            
            # JSON 파일 저장
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(json_data, f, ensure_ascii=False, indent=4)
            
            self.logger.info(f"JSON 파일 저장 완료: {filepath}")
            return filepath
            
        except Exception as e:
            self.logger.error(f"JSON 파일 저장 중 오류 발생: {str(e)}")
            raise
    
    def _sanitize_filename(self, filename: str) -> str:
        """
        파일명에서 사용할 수 없는 문자를 제거합니다.
        
        Args:
            filename (str): 원본 파일명
            
        Returns:
            str: 정리된 파일명
        """
        # 한글을 영문으로 변환하는 간단한 매핑
        korean_to_english = {
            '인하대학교': 'Inha_University',
            '서울대학교': 'Seoul_National_University',
            '연세대학교': 'Yonsei_University',
            '고려대학교': 'Korea_University',
            '카이스트': 'KAIST',
            '포스텍': 'POSTECH'
        }
        
        # 매핑된 이름이 있으면 사용
        if filename in korean_to_english:
            return korean_to_english[filename]
        
        # 그 외의 경우 한글 제거하고 영문만 유지
        import re
        safe_name = re.sub(r'[^\w\-_.]', '_', filename)
        return safe_name
    
    def list_saved_files(self) -> list:
        """
        저장된 JSON 파일 목록을 반환합니다.
        
        Returns:
            list: 파일 경로 목록
        """
        try:
            files = []
            for filename in os.listdir(self.output_dir):
                if filename.endswith('.json'):
                    files.append(os.path.join(self.output_dir, filename))
            return sorted(files)
        except Exception as e:
            self.logger.error(f"파일 목록 조회 중 오류 발생: {str(e)}")
            return []
    
    def load_json_file(self, filepath: str) -> Dict[str, Any]:
        """
        JSON 파일을 로드합니다.
        
        Args:
            filepath (str): 파일 경로
            
        Returns:
            Dict[str, Any]: JSON 데이터
        """
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            self.logger.error(f"JSON 파일 로드 중 오류 발생: {str(e)}")
            raise
    
    def merge_cafeteria_data(self, existing_data: Dict[str, Any], new_cafeteria_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        기존 데이터에 새로운 식당 정보를 병합합니다.
        
        Args:
            existing_data (Dict[str, Any]): 기존 JSON 데이터
            new_cafeteria_data (Dict[str, Any]): 새로운 식당 데이터
            
        Returns:
            Dict[str, Any]: 병합된 데이터
        """
        try:
            # 기존 데이터 복사
            merged_data = existing_data.copy()
            
            # 새로운 식당 정보 추출
            new_cafeterias = new_cafeteria_data.get('cafeterias', [])
            
            # 기존 식당 목록
            existing_cafeterias = merged_data.get('cafeterias', [])
            existing_cafeteria_names = {cafeteria['name'] for cafeteria in existing_cafeterias}
            
            # 새로운 식당 추가 (중복되지 않는 경우만)
            for new_cafeteria in new_cafeterias:
                cafeteria_name = new_cafeteria['name']
                if cafeteria_name not in existing_cafeteria_names:
                    existing_cafeterias.append(new_cafeteria)
                    self.logger.info(f"새로운 식당 추가: {cafeteria_name}")
                else:
                    # 기존 식당이 있으면 업데이트
                    for i, existing_cafeteria in enumerate(existing_cafeterias):
                        if existing_cafeteria['name'] == cafeteria_name:
                            existing_cafeterias[i] = new_cafeteria
                            self.logger.info(f"기존 식당 업데이트: {cafeteria_name}")
                            break
            
            merged_data['cafeterias'] = existing_cafeterias
            return merged_data
            
        except Exception as e:
            self.logger.error(f"식당 데이터 병합 중 오류 발생: {str(e)}")
            raise
    
    def find_existing_file(self, date: str, school_name: str) -> str:
        """
        특정 날짜와 학교의 기존 JSON 파일을 찾습니다.
        
        Args:
            date (str): 날짜 (YYYY-MM-DD)
            school_name (str): 학교 이름
            
        Returns:
            str: 파일 경로 (없으면 None)
        """
        try:
            safe_school_name = self._sanitize_filename(school_name)
            filename = f"{safe_school_name}_{date}.json"
            filepath = os.path.join(self.output_dir, filename)
            
            if os.path.exists(filepath):
                return filepath
            return None
            
        except Exception as e:
            self.logger.error(f"기존 파일 찾기 중 오류 발생: {str(e)}")
            return None
