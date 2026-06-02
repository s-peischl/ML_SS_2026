#!/usr/bin/env bash
# Render slide decks as Reveal.js (not website HTML). Called from project pre-render.
set -euo pipefail
cd "$(dirname "$0")/.."
quarto render slides/day-01-monday.qmd
quarto render slides/day-02-tuesday.qmd
quarto render slides/day-04-thursday.qmd
