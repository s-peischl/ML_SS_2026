#!/usr/bin/env python3
"""Validate href/src in rendered _site HTML (excludes vendor JS bundles)."""

from __future__ import annotations

import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"

HREF_RE = re.compile(r'''(?:href|src)=["']([^"']+)["']''', re.I)
SKIP_PREFIX = ("mailto:", "tel:", "javascript:", "data:", "#")
SKIP_PARTS = {"site_libs"}


def collect_html_files() -> list[Path]:
    return [f for f in SITE.rglob("*.html") if not any(p in SKIP_PARTS for p in f.parts)]


def normalize_target(from_file: Path, url: str) -> Path | None:
    u = url.split("#")[0].split("?")[0]
    if not u or u.startswith(SKIP_PREFIX):
        return None
    if u.startswith("http://") or u.startswith("https://"):
        return None
    if u.startswith("?"):
        return from_file
    if u.startswith("/"):
        return SITE / u.lstrip("/")
    return (from_file.parent / u).resolve()


def exists(path: Path) -> bool:
    if path.exists() and path.is_file():
        return True
    for ext in (".qmd", ".Rmd", ".md"):
        if path.suffix == ext:
            hp = path.with_suffix(".html")
            if hp.exists():
                return True
    if not path.suffix:
        for c in [path.with_suffix(".html"), path / "index.html"]:
            if c.exists():
                return True
    return False


def is_real_url(url: str) -> bool:
    if "${" in url or url in {"t", "s", "e"}:
        return False
    if re.match(r"^[a-zA-Z_$][\w$]*$", url):
        return False
    return True


def curl_code(url: str) -> str:
    r = subprocess.run(
        ["curl", "-sL", "-o", "/dev/null", "-w", "%{http_code}", "--max-time", "25", url],
        capture_output=True,
        text=True,
    )
    return r.stdout.strip() or "ERR"


def main() -> int:
    if not SITE.exists():
        print("ERROR: run `quarto render` first", file=sys.stderr)
        return 2

    files = collect_html_files()
    internal: dict[str, set[str]] = {}
    external: dict[str, set[str]] = {}

    for f in files:
        rel = str(f.relative_to(SITE))
        for m in HREF_RE.finditer(f.read_text(encoding="utf-8", errors="replace")):
            url = m.group(1)
            if url.startswith(SKIP_PREFIX) or not url.strip():
                continue
            if url.startswith("http://") or url.startswith("https://"):
                external.setdefault(url, set()).add(rel)
            elif is_real_url(url):
                internal.setdefault(url, set()).add(rel)

    int_fail = []
    for url, sources in sorted(internal.items()):
        src = SITE / next(iter(sources))
        target = normalize_target(src, url)
        if target is None:
            continue
        if not exists(target):
            int_fail.append((url, sources, target))

    ext_fail = []
    with ThreadPoolExecutor(max_workers=16) as pool:
        futs = {pool.submit(curl_code, u): u for u in external}
        for fut in as_completed(futs):
            u = futs[fut]
            code = fut.result()
            if not code.startswith(("2", "3")):
                ext_fail.append((u, code, external[u]))

    rc_links = [(u, s) for u, s in internal.items() if "modules/" in u]
    rc_broken = [(u, s) for u, s, _ in int_fail if "modules/" in u]

    print(f"Scanned {len(files)} HTML pages")
    print(f"Reading companion hrefs: {len(rc_links)} total, {len(rc_broken)} broken")

    print("\n=== BROKEN INTERNAL (all) ===")
    if not int_fail:
        print("(none)")
    for url, sources, target in int_fail:
        print(f"  {url}")
        print(f"    -> {target}")
        print(f"    in: {', '.join(sorted(sources)[:3])}")

    print("\n=== BROKEN EXTERNAL ===")
    if not ext_fail:
        print("(none)")
    for url, code, sources in sorted(ext_fail):
        print(f"  [{code}] {url}")

    print(f"\nRESULT: {len(int_fail)} internal, {len(ext_fail)} external failures")
    return 1 if int_fail or ext_fail else 0


if __name__ == "__main__":
    raise SystemExit(main())
