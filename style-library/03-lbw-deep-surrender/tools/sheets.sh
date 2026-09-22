#!/bin/bash
# Build contact-sheet.png and face-clearance.png in the pack's preview/ (runs on the Mini).
# usage: ssh mac-mini-remote 'bash -s' < lbw03-sheets.sh
set -eu
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
K=$HOME/Developer/hyperframes-student-kit
P=$K/style-library/03-lbw-deep-surrender
cd "$P/preview"
ID=lbw-deep-surrender

# contact sheet: 4 x 3 grid of 640x360 posters on Abyss, in taxonomy order
order="t1.thesis t1.stat t1.section t1.quote t1.overview t2.lower-third t2.label t2.list t2.definition custom.breath-pacer custom.caption-box custom.end-card"
inputs=""; filt=""; n=0; layout=""
for c in $order; do
  inputs="$inputs -i $ID.$c.png"
  filt="$filt[$n:v]scale=640:360,pad=660:380:10:10:color=0x0a1628[v$n];"
  col=$((n % 4)); row=$((n / 4))
  layout="$layout$((col * 660))_$((row * 380))|"
  n=$((n + 1))
done
stack=""; for i in $(seq 0 11); do stack="$stack[v$i]"; done
ffmpeg -v error -y $inputs -filter_complex "${filt}${stack}xstack=inputs=12:layout=${layout%|}:fill=0x0a1628[out]" -map "[out]" -frames:v 1 contact-sheet.png

# face clearance: every overlay card composited over the same real speaker frame,
# with the measured face zone (x 520-930, y 180-690) outlined in Abyss
box="drawbox=x=520:y=180:w=410:h=510:color=0x0a1628@0.9:t=6"
ffmpeg -v error -y \
  -i /tmp/lbw03/f20.jpg -i $ID.t2.lower-third.png -i $ID.t2.label.png \
  -i $ID.t2.list.png -i $ID.t2.definition.png -i $ID.custom.caption-box.png \
  -filter_complex "\
[0:v]scale=1920:1080,$box,scale=960:540[a];[1:v]$box,scale=960:540[b];[2:v]$box,scale=960:540[c];\
[3:v]$box,scale=960:540[d];[4:v]$box,scale=960:540[e];[5:v]$box,scale=960:540[f];\
[a][b][c][d][e][f]xstack=inputs=6:layout=0_0|960_0|1920_0|0_540|960_540|1920_540[out]" \
  -map "[out]" -frames:v 1 face-clearance.png
ls -la contact-sheet.png face-clearance.png
