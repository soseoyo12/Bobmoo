from __future__ import annotations

import json
import os
import sys
import tempfile
from dataclasses import dataclass
from typing import Literal, Optional

from schemas import Meals


ReviewAction = Literal["approve", "edit", "retry", "skip", "quit", "open"]


@dataclass
class ReviewItem:
    image_path: str
    meals: Meals
    raw_json: str


class ReviewManager:
    """
    간단한 CLI 기반 검토 관리자.

    - 이미지 경로 출력 및 (옵션) 이미지 열기
    - JSON 미리보기 후 승인/수정/재시도 선택
    - 수정은 임시파일을 메모장으로 열어 편집하도록 지원(Windows)
    """

    def __init__(self, auto_open_image: bool = False):
        self.auto_open_image = auto_open_image

    def _prompt_action(self) -> ReviewAction:
        while True:
            choice = input("[A]승인 [E]수정 [R]재시도 [O]이미지열기 [S]건너뛰기 [Q]종료 > ").strip().lower()
            if choice in ("a", "e", "r", "s", "q", "o"):
                return {
                    "a": "approve",
                    "e": "edit",
                    "r": "retry",
                    "s": "skip",
                    "q": "quit",
                    "o": "open",
                }[choice]

    def _open_image(self, path: str) -> None:
        try:
            if os.name == "nt":
                os.startfile(path)  # type: ignore[attr-defined]
            elif os.name == "posix":
                # macOS 또는 Linux
                opener = "open" if sys.platform == "darwin" else "xdg-open"
                os.spawnlp(os.P_NOWAIT, opener, opener, path)
        except Exception as e:
            print(f"이미지 열기 실패: {e}")

    def _open_editor_and_load(self, initial_json: str) -> Optional[Meals]:
        """
        임시 파일을 생성해 메모장(Windows)으로 열고 저장 후 다시 읽어들인다.
        실패 시 None 반환.
        """
        try:
            with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8") as tmp:
                tmp.write(initial_json)
                tmp_path = tmp.name
            try:
                if os.name == "nt":
                    os.startfile(tmp_path)  # type: ignore[attr-defined]
                    input("메모장에서 수정 후 저장하고 닫으세요. 완료하면 Enter를 누르세요...")
                else:
                    editor = os.environ.get("EDITOR", "vi")
                    os.system(f"{editor} '{tmp_path}'")
            finally:
                with open(tmp_path, "r", encoding="utf-8") as f:
                    edited = f.read()
                try:
                    data = json.loads(edited)
                    return Meals(**data) if isinstance(data, dict) else None
                finally:
                    try:
                        os.remove(tmp_path)
                    except Exception:
                        pass
        except Exception as e:
            print(f"편집 중 오류: {e}")
            return None

    def review(self, item: ReviewItem) -> tuple[str, Meals | None]:
        """
        단일 항목을 검토하고 다음 액션을 반환한다.

        Returns:
            (action, meals or None)
            action ∈ {"approve","edit","retry","skip","quit"}
        """
        print("\n===== 검토 =====")
        print(f"이미지: {item.image_path}")
        if self.auto_open_image:
            self._open_image(item.image_path)

        # JSON 미리보기(짧게)
        try:
            print(json.dumps(item.meals.model_dump(), ensure_ascii=False, indent=2))
        except Exception:
            print(item.raw_json)

        while True:
            action = self._prompt_action()
            if action == "open":
                self._open_image(item.image_path)
                continue
            if action == "approve":
                return action, item.meals
            if action == "retry":
                return action, None
            if action == "skip":
                return action, None
            if action == "quit":
                return action, None
            if action == "edit":
                edited = self._open_editor_and_load(
                    json.dumps(item.meals.model_dump(), ensure_ascii=False, indent=2)
                )
                if edited is not None:
                    return "approve", edited
                print("JSON 파싱 실패 또는 편집 취소. 다시 선택하세요.")


