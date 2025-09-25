# -*- coding: utf-8 -*-
from __future__ import annotations

import argparse
from pathlib import Path
from .pipeline import transform_from_url


def main() -> None:
    parser = argparse.ArgumentParser(description="Crawl cafeteria menus and export to standard JSON")
    parser.add_argument("url", help="Target menu page URL")
    parser.add_argument("--out", dest="out", default="out", help="Output directory base")
    args = parser.parse_args()

    data = transform_from_url(args.url, out_dir=args.out)
    print(f"Saved for school={data.get('school')} date={data.get('date')}")


if __name__ == "__main__":
    main()

