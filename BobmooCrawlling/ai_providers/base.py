from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any

from schemas import Meals


class AIProvider(ABC):
    """
    AI 제공자를 위한 추상 기본 클래스.
    
    모든 AI Provider는 이 클래스를 상속받아 구현해야 합니다.
    다형성을 통해 다양한 AI 서비스를 동일한 인터페이스로 사용할 수 있습니다.
    """
    
    @abstractmethod
    def analyze(self, image_path: str) -> Any:
        """
        이미지를 분석하여 원시 응답을 반환합니다.
        
        Args:
            image_path: 분석할 이미지 파일 경로
            
        Returns:
            AI 서비스별 원시 응답 (문자열, dict, list 등)
        """
        pass
    
    @abstractmethod
    def normalize_response(self, raw_response: Any) -> Meals:
        """
        AI 서비스의 원시 응답을 Meals 스키마로 정규화합니다.
        
        각 Provider는 자신의 응답 형식에 맞게 이 메서드를 구현해야 합니다.
        이를 통해 유연하게 다양한 출력 형식을 지원할 수 있습니다.
        
        Args:
            raw_response: analyze() 메서드에서 반환된 원시 응답
            
        Returns:
            정규화된 Meals 인스턴스
        """
        pass
    
    @abstractmethod
    def get_provider_name(self) -> str:
        """
        Provider 이름을 반환합니다.
        
        Returns:
            Provider 이름 (예: "Gemini", "Upstage")
        """
        pass
    
    def analyze_and_normalize(self, image_path: str) -> Meals:
        """
        이미지를 분석하고 정규화된 Meals를 반환하는 편의 메서드.
        
        Args:
            image_path: 분석할 이미지 파일 경로
            
        Returns:
            정규화된 Meals 인스턴스
        """
        raw_response = self.analyze(image_path)
        return self.normalize_response(raw_response)

