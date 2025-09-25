# -*- coding: utf-8 -*-
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional
import time

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager


@dataclass
class SeleniumResult:
    url: str
    html: str


def fetch_html_with_selenium(url: str, *, wait_selector: Optional[str] = None, timeout: int = 15, headless: bool = True) -> SeleniumResult:
    options = Options()
    if headless:
        options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-dev-shm-usage")

    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    try:
        driver.get(url)
        if wait_selector:
            WebDriverWait(driver, timeout).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, wait_selector))
            )
        else:
            WebDriverWait(driver, timeout).until(lambda d: d.execute_script("return document.readyState") == "complete")
        html = driver.page_source
        return SeleniumResult(url=driver.current_url, html=html)
    finally:
        driver.quit()

