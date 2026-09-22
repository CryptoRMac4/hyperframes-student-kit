#!/bin/bash
# SI Desert Authority preview tooling. Run from the kit copy of this pack
# (style-library/04-si-desert-authority/tools/) on the render machine.
#   si-batch.sh lint                   lint every card with the kit's pinned hyperframes
#   si-batch.sh render [id-substr]     render cards to preview/<id>.mp4 + poster PNG
#   si-batch.sh sheet                  contact sheet from the posters
#   si-batch.sh face <video> [secs]    composite tier2 cards over a talking-head frame
set -uo pipefail
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
PACK="$(cd "$(dirname "$0")/.." && pwd)"
KIT="$(cd "$PACK/../.." && pwd)"
HF="$KIT/node_modules/.bin/hyperframes"
S=si-desert-authority
# id | card file | poster time (most representative frame)
CARDS="$S.t1.thesis|cards/tier1/t1-thesis.html|3.0
$S.t1.stat|cards/tier1/t1-stat.html|3.0
$S.t1.section|cards/tier1/t1-section.html|2.5
$S.t1.quote|cards/tier1/t1-quote.html|3.5
$S.t1.overview|cards/tier1/t1-overview.html|4.5
$S.t2.lower-third|cards/tier2/t2-lower-third.html|2.0
$S.t2.label|cards/tier2/t2-label.html|2.0
$S.t2.list|cards/tier2/t2-list.html|3.5
$S.t2.definition|cards/tier2/t2-definition.html|2.5
$S.custom.before-after|cards/custom/c-before-after.html|4.5
$S.custom.score-gauge|cards/custom/c-score-gauge.html|4.0
$S.custom.ranking-climb|cards/custom/c-ranking-climb.html|4.3
$S.custom.end-card|cards/custom/c-end-card.html|4.0"

case "${1:-}" in
lint)
  T=$(mktemp -d "${TMPDIR:-/tmp}/si-lint.XXXX"); total=0
  while IFS='|' read -r id file at; do
    [[ -n "${2:-}" && "$id" != *"$2"* ]] && continue
    D="$T/$id"; mkdir -p "$D"
    cp -R "$PACK/tokens.css" "$PACK/fonts" "$PACK/assets" "$D/"
    # card as project index; the ../../ contract paths become root-relative
    sed 's#\.\./\.\./##g' "$PACK/$file" > "$D/index.html"
    out=$(cd "$D" && "$HF" lint . 2>&1)
    line=$(echo "$out" | grep -E "errors?," | tail -1)
    echo "$id :: $line"
    echo "$out" | grep -E "^\s+[✗⚠]" | sed 's/^/    /'
    n=$(echo "$line" | grep -oE "[0-9]+ error" | grep -oE "[0-9]+"); total=$((total + ${n:-99}))
  done <<< "$CARDS"
  echo "TOTAL LINT ERRORS: $total"
  ;;
render)
  mkdir -p "$PACK/preview"; cd "$PACK"
  while IFS='|' read -r id file at; do
    [[ -n "${2:-}" && "$id" != *"$2"* ]] && continue
    "$HF" render . -c "$file" -o "preview/$id.mp4" -q draft -w 1 --quiet > /dev/null 2>&1
    rc=$?
    ffmpeg -y -loglevel error -ss "$at" -i "preview/$id.mp4" -frames:v 1 "preview/$id.png"
    echo "$id rc=$rc"
  done <<< "$CARDS"
  ;;
sheet)
  T=$(mktemp -d "${TMPDIR:-/tmp}/si-sheet.XXXX"); i=0
  while IFS='|' read -r id file at; do
    i=$((i+1)); cp "$PACK/preview/$id.png" "$T/$(printf %02d $i).png"
  done <<< "$CARDS"
  for j in 14 15 16; do ffmpeg -y -loglevel error -f lavfi -i color=c=0x2D3A2E:s=1920x1080 -frames:v 1 "$T/$j.png"; done
  ffmpeg -y -loglevel error -framerate 1 -i "$T/%02d.png" -vf "scale=640:360,tile=4x4:padding=16:margin=16:color=0x1d251e" -frames:v 1 "$PACK/preview/$S.contact-sheet.png"
  echo "preview/$S.contact-sheet.png"
  ;;
face)
  SRC="${2:?talking-head video path}"; SEC="${3:-95}"
  cd "$PACK"; T=$(mktemp -d "${TMPDIR:-/tmp}/si-face.XXXX")
  ffmpeg -y -loglevel error -ss "$SEC" -i "$SRC" -frames:v 1 -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" "$T/bg.png"
  for row in "t2.lower-third|cards/tier2/t2-lower-third.html|2.0" "t2.list|cards/tier2/t2-list.html|3.5" "t2.definition|cards/tier2/t2-definition.html|2.5" "t2.label|cards/tier2/t2-label.html|2.0"; do
    IFS='|' read -r k file at <<< "$row"
    "$HF" render . -c "$file" -o "$T/$k.mov" --format mov -w 1 --quiet > /dev/null 2>&1
    ffmpeg -y -loglevel error -ss "$at" -i "$T/$k.mov" -frames:v 1 -pix_fmt rgba "$T/$k.png"
    ffmpeg -y -loglevel error -i "$T/bg.png" -i "$T/$k.png" -filter_complex "[0][1]overlay=0:0" "preview/$S.$k.face-clearance.png"
    echo "preview/$S.$k.face-clearance.png"
  done
  ;;
*) sed -n 2,8p "$0" ;;
esac
