# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Tuple
import time

import requests
from requests import Response
from charset_normalizer import from_bytes


DEFAULT_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    )
}


@dataclass
class FetchResult:
    url: str
    status_code: int
    content_bytes: bytes
    text: str
    encoding: str


def _detect_encoding(content: bytes, fallback: str = "utf-8") -> Tuple[str, str]:
    """
    Return tuple(normalized_text, encoding_name) using charset-normalizer.
    Fallback to provided encoding when detection fails.
    """
    if not content:
        return "", fallback
    best = from_bytes(content).best()
    if best is None:
        try:
            return content.decode(fallback, errors="replace"), fallback
        except Exception:
            return content.decode("utf-8", errors="replace"), "utf-8"
    return str(best), best.encoding or fallback


def _perform_request(session: requests.Session, url: str, timeout: int) -> Response:
    return session.get(
        url,
        headers=DEFAULT_HEADERS,
        timeout=timeout,
        allow_redirects=True,
        stream=False,
    )


def fetch_url(
    url: str,
    *,
    max_retries: int = 3,
    initial_backoff_sec: float = 0.5,
    timeout_sec: int = 15,
) -> FetchResult:
    """
    Fetch URL with retries and normalize encoding.

    - Retries with exponential backoff on network/5xx errors
    - Uses charset-normalizer to produce clean UTF-8 text
    """
    session = requests.Session()
    last_exc: Optional[Exception] = None
    backoff = initial_backoff_sec

    for attempt in range(1, max_retries + 1):
        try:
            resp = _perform_request(session, url, timeout_sec)
            status = resp.status_code
            # Retry on 5xx
            if status >= 500:
                raise RuntimeError(f"server error: {status}")
            content = resp.content or b""
            text, enc = _detect_encoding(content, fallback=(resp.encoding or "utf-8"))
            return FetchResult(
                url=str(resp.url),
                status_code=status,
                content_bytes=content,
                text=text,
                encoding=enc,
            )
        except Exception as exc:  # network/timeout/5xx
            last_exc = exc
            if attempt >= max_retries:
                break
            time.sleep(backoff)
            backoff *= 2
    raise RuntimeError(f"Failed to fetch URL after {max_retries} attempts: {last_exc}")

