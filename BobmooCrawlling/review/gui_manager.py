from __future__ import annotations

import json
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
from typing import Optional
from PIL import Image, ImageTk
import threading

from schemas import Meals
from review.manager import ReviewItem


class GUIReviewManager:
    """
    GUI 기반 검토 관리자.
    
    - 왼쪽에 이미지 표시
    - 오른쪽에 JSON 편집 가능한 텍스트 영역
    - 오른쪽 아래에 수락/재요청 버튼
    - 수정은 항상 가능 (텍스트 영역에서 직접 수정)
    """
    
    def __init__(self):
        self.result_action: Optional[str] = None
        self.result_meals: Optional[Meals] = None
        self.window: Optional[tk.Tk] = None
        self.text_widget: Optional[scrolledtext.ScrolledText] = None
        self.image_label: Optional[tk.Label] = None
        self.photo: Optional[ImageTk.PhotoImage] = None  # 이미지 참조 유지용
        self._lock = threading.Lock()
        self._waiting = False
    
    def _load_image(self, image_path: str, master: tk.Tk, max_width: int = 600, max_height: int = 800) -> Optional[ImageTk.PhotoImage]:
        """이미지를 로드하고 크기를 조정합니다."""
        try:
            img = Image.open(image_path)
            # 비율 유지하면서 크기 조정
            img.thumbnail((max_width, max_height), Image.Resampling.LANCZOS)
            # master를 명시적으로 지정하여 Tk 루트와 연결
            return ImageTk.PhotoImage(img, master=master)
        except Exception as e:
            print(f"이미지 로드 실패: {e}")
            return None
    
    def _parse_json(self, json_text: str) -> Optional[Meals]:
        """JSON 텍스트를 파싱하여 Meals 객체로 변환합니다."""
        try:
            data = json.loads(json_text)
            return Meals(**data) if isinstance(data, dict) else None
        except Exception as e:
            return None
    
    def _on_approve(self):
        """수락 버튼 클릭 시 호출됩니다."""
        if self.text_widget is None:
            return
        
        json_text = self.text_widget.get("1.0", tk.END).strip()
        meals = self._parse_json(json_text)
        
        if meals is None:
            messagebox.showerror("오류", "JSON 형식이 올바르지 않습니다. 수정 후 다시 시도하세요.")
            return
        
        with self._lock:
            self.result_action = "approve"
            self.result_meals = meals
            self._waiting = False
        
        if self.window:
            self.window.quit()
            self.window.destroy()
    
    def _on_retry(self):
        """재요청 버튼 클릭 시 호출됩니다."""
        with self._lock:
            self.result_action = "retry"
            self.result_meals = None
            self._waiting = False
        
        if self.window:
            self.window.quit()
            self.window.destroy()
    
    def _on_skip(self):
        """건너뛰기 버튼 클릭 시 호출됩니다."""
        with self._lock:
            self.result_action = "skip"
            self.result_meals = None
            self._waiting = False
        
        if self.window:
            self.window.quit()
            self.window.destroy()
    
    def _on_quit(self):
        """종료 버튼 클릭 시 호출됩니다."""
        with self._lock:
            self.result_action = "quit"
            self.result_meals = None
            self._waiting = False
        
        if self.window:
            self.window.quit()
            self.window.destroy()
    
    def review(self, item: ReviewItem) -> tuple[str, Meals | None]:
        """
        단일 항목을 GUI로 검토하고 다음 액션을 반환합니다.
        
        Returns:
            (action, meals or None)
            action ∈ {"approve","retry","skip","quit"}
        """
        # 결과 초기화
        with self._lock:
            self.result_action = None
            self.result_meals = None
            self._waiting = True
        
        # GUI 창 생성
        self.window = tk.Tk()
        self.window.title("식단 검토")
        self.window.geometry("1200x800")
        
        # 메인 프레임 (가로 분할)
        main_frame = ttk.Frame(self.window, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # 왼쪽: 이미지 영역
        left_frame = ttk.Frame(main_frame)
        left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 10))
        
        image_label = ttk.Label(left_frame, text="이미지 로딩 중...")
        image_label.pack(expand=True)
        
        # 이전 이미지 참조 정리
        self.photo = None
        
        photo = self._load_image(item.image_path, master=self.window)
        if photo:
            # 인스턴스 변수로 참조 유지 (가비지 컬렉션 방지)
            self.photo = photo
            image_label.config(image=photo, text="")
            # 추가 안전장치: 위젯에도 참조 저장
            image_label.image = photo
        
        self.image_label = image_label
        
        # 오른쪽: JSON 편집 영역
        right_frame = ttk.Frame(main_frame)
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)
        
        # JSON 텍스트 영역
        text_label = ttk.Label(right_frame, text="JSON (수정 가능):")
        text_label.pack(anchor=tk.W, pady=(0, 5))
        
        text_widget = scrolledtext.ScrolledText(
            right_frame,
            wrap=tk.WORD,
            font=("Consolas", 10),
            width=50
        )
        text_widget.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        # 초기 JSON 텍스트 삽입
        initial_json = json.dumps(item.meals.model_dump(), ensure_ascii=False, indent=2)
        text_widget.insert("1.0", initial_json)
        self.text_widget = text_widget
        
        # 버튼 영역 (오른쪽 아래)
        button_frame = ttk.Frame(right_frame)
        button_frame.pack(fill=tk.X, side=tk.BOTTOM)
        
        # 재요청 버튼
        retry_btn = ttk.Button(button_frame, text="재요청", command=self._on_retry)
        retry_btn.pack(side=tk.RIGHT, padx=(5, 0))
        
        # 수락 버튼
        approve_btn = ttk.Button(button_frame, text="수락", command=self._on_approve)
        approve_btn.pack(side=tk.RIGHT)
        
        # 창 닫기 이벤트 처리
        def on_closing():
            self._on_quit()
        
        self.window.protocol("WM_DELETE_WINDOW", on_closing)
        
        # GUI 이벤트 루프 실행
        self.window.mainloop()
        
        # 결과 반환
        with self._lock:
            action = self.result_action or "quit"
            meals = self.result_meals
            self.window = None
            self.text_widget = None
            self.image_label = None
            self.photo = None  # 이미지 참조 정리
        
        return action, meals

