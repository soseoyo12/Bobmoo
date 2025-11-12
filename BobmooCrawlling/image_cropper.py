from __future__ import annotations

import os
from typing import List, Tuple

from PIL import Image


def _ensure_dir(path: str) -> None:
    if not os.path.isdir(path):
        os.makedirs(path, exist_ok=True)


def crop_and_compose(
    input_image_path: str,
    output_dir: str,
    *,
    left_margin_ratio: float = 0.018,
    right_margin_ratio: float = 0.018,
    top_margin_ratio: float = 0.072,
    bottom_margin_ratio: float = 0.12,
    col_ratios: List[float] | None = None,
    background_color: Tuple[int, int, int] = (255, 255, 255),
) -> List[str]:
    """
    주간 식단 이미지를 비율 기반으로 세로 열로 자르고, '구분' 열과 각 요일 열을 가로로 이어붙여
    요일별 합성 이미지를 생성한다.

    Returns:
        생성된 요일별 합성 이미지 경로 리스트(월→일 순).
    """

    if col_ratios is None:
        # 총 8열: 구분 + 월~일
        col_ratios = [0.125] * 8

    img = Image.open(input_image_path)
    width, height = img.size

    # 외곽 여백 제거 영역 계산
    left = int(width * left_margin_ratio)
    right = width - int(width * right_margin_ratio)
    top = int(height * top_margin_ratio)
    bottom = height - int(height * bottom_margin_ratio)

    crop_width = right - left
    crop_height = bottom - top

    # 각 열 크롭
    columns: List[Image.Image] = []
    acc = 0.0
    for ratio in col_ratios:
        # 가로 길이 계산
        x = left + int(acc * crop_width)
        w = int(ratio * crop_width)
        # 세로 길이 계산
        y = top
        h = crop_height
        col_img = img.crop((x, y, x + w, y + h))
        columns.append(col_img)
        acc += ratio

    if len(columns) < 8:
        raise ValueError("열 개수(col_ratios)가 8 미만입니다. 구분+월~일 합계 8개가 필요합니다.")

    # 구분 열 + 각 요일 열 합성 (월~일 → index 1..7)
    legend_col = columns[0]
    out_paths: List[str] = []
    _ensure_dir(output_dir)

    day_names = [
        "mon", "tue", "wed", "thu", "fri", "sat", "sun"
    ]
    for day_idx, day_col in enumerate(columns[1:8], start=0):
        composed_width = legend_col.width + day_col.width
        composed_height = max(legend_col.height, day_col.height)
        canvas = Image.new("RGB", (composed_width, composed_height), background_color)
        canvas.paste(legend_col, (0, 0))
        canvas.paste(day_col, (legend_col.width, 0))

        out_name = f"{day_names[day_idx]}.png"
        out_path = os.path.join(output_dir, out_name)
        canvas.save(out_path)
        out_paths.append(out_path)

    return out_paths


__all__ = ["crop_and_compose"]

