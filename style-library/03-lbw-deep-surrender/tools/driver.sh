#!/bin/bash
# Mini-side driver for the 03-lbw-deep-surrender pack.
# usage: ssh mac-mini-remote 'bash -s' -- <mode> [card-basename ...] < lbw03-driver.sh
#   modes: lint | check | snap | render
# Each card is localized into tmp/lbw03/<card>/ (tokens + fonts beside index.html),
# which is how the kit expects a card to be copied into a project.
# tier2 and caption cards also get a <card>-bg variant with a real speaker frame
# behind them, used for posters, preview renders, and the face-clearance proof.
set -u
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
K=$HOME/Developer/hyperframes-student-kit
cd "$K" || exit 1
P=style-library/03-lbw-deep-surrender
BG=/tmp/lbw03/f20.jpg
MODE=$1; shift
CARDS=("$@")
if [ ${#CARDS[@]} -eq 0 ]; then
  CARDS=(t1-thesis t1-stat t1-section t1-quote t1-overview t2-lower-third t2-label t2-list t2-definition c-breath-pacer c-caption-box c-end-card)
fi
mkdir -p "$P/preview"

card_id() {
  case $1 in
    t1-*) echo "lbw-deep-surrender.t1.${1#t1-}" ;;
    t2-*) echo "lbw-deep-surrender.t2.${1#t2-}" ;;
    c-*)  echo "lbw-deep-surrender.custom.${1#c-}" ;;
  esac
}
hero() {
  case $1 in
    t1-thesis) echo 3.5 ;; t1-stat) echo 3.6 ;; t1-section) echo 3.4 ;; t1-quote) echo 3.8 ;;
    t1-overview) echo 4.4 ;; t2-lower-third) echo 3.0 ;; t2-label) echo 2.6 ;; t2-list) echo 3.9 ;;
    t2-definition) echo 3.4 ;; c-breath-pacer) echo 7.6 ;; c-caption-box) echo 1.5 ;; c-end-card) echo 4.6 ;;
  esac
}
needs_bg() { case $1 in t2-*|c-caption-box) return 0 ;; *) return 1 ;; esac; }
src() { ls $P/cards/*/$1.html; }

prep() {  # $1 card, $2 "bg" or ""
  local T=tmp/lbw03/$1${2:+-bg}
  rm -rf "$T"; mkdir -p "$T"; cp -R $P/fonts $P/tokens.css "$T/"
  if [ -n "${2:-}" ]; then
    cp "$BG" "$T/speaker.jpg"
    sed -e 's#\.\./\.\./tokens\.css#tokens.css#' \
        -e 's#<body>#<body><img src="speaker.jpg" alt="" data-layout-ignore style="position:absolute;left:0;top:0;width:1920px;height:1080px">#' \
        "$(src $1)" > "$T/index.html"
  else
    sed 's#\.\./\.\./tokens\.css#tokens.css#' "$(src $1)" > "$T/index.html"
  fi
  echo "$T"
}

for b in "${CARDS[@]}"; do
  id=$(card_id $b)
  case $MODE in
    lint)
      T=$(prep $b); echo "== $b"
      npx hyperframes lint "$T" 2>&1 | grep -E "errors?,|✗|error" | head -8 ;;
    check)
      T=$(prep $b); echo "== $b"
      npx hyperframes check "$T" 2>&1 | grep -E "✗|⚠|◇|error\(s\)|Check (passed|failed)|^\s+(✗|⚠)" | grep -v "ℹ" | head -20 ;;
    snap)
      if needs_bg $b; then T=$(prep $b bg); else T=$(prep $b); fi
      npx hyperframes snapshot "$T" --at "$(hero $b)" --no-end -o "$T/snaps" --describe false >/dev/null 2>&1
      f=$(ls "$T"/snaps/frame-00-*.png 2>/dev/null | head -1)
      if [ -n "$f" ]; then cp "$f" "$P/preview/$id.png"; echo "poster $id.png"; else echo "SNAPSHOT FAILED $b"; fi ;;
    render)
      if needs_bg $b; then T=$(prep $b bg); else T=$(prep $b); fi
      out="$K/$P/preview/$id.mp4"
      npx hyperframes render "$T" -o "$out" --quality draft --workers 2 --quiet >/tmp/lbw03/render-$b.log 2>&1
      if [ -s "$out" ]; then
        echo "render $id.mp4 $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$out")s"
      else
        echo "RENDER FAILED $b"; tail -5 /tmp/lbw03/render-$b.log
      fi ;;
  esac
done
