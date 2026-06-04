#!/usr/bin/env bash
# Export Reveal slide decks to PDF.
#
# Method A (always works): prints instructions for browser export (?print-pdf).
# Method B (automated): uses decktape if installed (npm i -g decktape).
#
# Usage:
#   ./scripts/export-slides-pdf.sh              # all three day decks
#   ./scripts/export-slides-pdf.sh day-01-monday
#
set -euo pipefail
cd "$(dirname "$0")/.."

DECKS=(day-01-monday day-02-tuesday day-04-thursday)
if [[ "${1:-}" != "" ]]; then
  DECKS=("$1")
fi

OUT_DIR="slides/pdf"
PORT="${PDF_EXPORT_PORT:-8765}"
mkdir -p "$OUT_DIR"

echo "Rendering slide HTML (if needed)..."
./scripts/render-slides.sh

if ! command -v decktape >/dev/null 2>&1; then
  echo ""
  echo "=== Printable slides (browser) ==="
  echo "decktape not found — use Chrome or Chromium:"
  echo ""
  echo "  1. quarto preview"
  echo "  2. Open each deck with ?print-pdf appended, e.g.:"
  for deck in "${DECKS[@]}"; do
    echo "     http://localhost:<port>/slides/${deck}.html?print-pdf"
  done
  echo "  3. Ctrl/Cmd+P → Save as PDF"
  echo "     Layout: Landscape · Margins: None · Background graphics: ON"
  echo ""
  echo "Or install decktape for one-command export:"
  echo "  npm install -g decktape"
  echo "  ./scripts/export-slides-pdf.sh"
  exit 0
fi

echo "Starting static server on port ${PORT}..."
python3 -m http.server "$PORT" --directory _site >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null || true' EXIT
sleep 1

for deck in "${DECKS[@]}"; do
  url="http://127.0.0.1:${PORT}/slides/${deck}.html"
  out="${OUT_DIR}/${deck}.pdf"
  echo "Exporting ${deck} → ${out}"
  decktape reveal "$url" "$out" --size 1920x1080
done

echo "Done. PDFs in ${OUT_DIR}/"
