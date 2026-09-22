#!/usr/bin/env bash
# Records the install demo and writes docs/demo/install.gif and install.mp4.
#
#   docs/demo/render.sh <left.env> <right.env>
#
# Each file exports, for one EMPTY Supabase project nobody minds losing:
# EKWO_DB_URL, SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY and
# EKWO_PASSWORD — the password the administrator the tape creates is given.
# The left file serves gb.tape, the right one ee.tape. The tapes install
# Ekwo OS into those projects, create an administrator and a company, and
# post into it.
#
# Needs vhs (https://github.com/charmbracelet/vhs) and ffmpeg.
#
# Two projects, recorded at the same time, so that the two halves do the same
# work at the same moment and neither country is the one the demo is about.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
if [ $# -ne 2 ] || [ ! -f "$1" ] || [ ! -f "$2" ]; then
  echo "usage: render.sh <left.env> <right.env>" >&2; exit 2
fi
command -v vhs >/dev/null || { echo "render.sh: vhs is not installed" >&2; exit 2; }
command -v ffmpeg >/dev/null || { echo "render.sh: ffmpeg is not installed" >&2; exit 2; }

work="$(mktemp -d /tmp/ekwo-demo.XXXXXX)"

# The release on npm today, fetched once: the two halves start at the same
# moment, and two npx installing one package into one cache break each other.
# From $work, not from this repository, where the workspace called ekwo-os
# would answer for the name.
(cd "$work" && npx --yes --prefer-online ekwo-os --version && npx --yes --prefer-online @ekwo-ai/mcp --version) >/dev/null 2>&1
record() {
  local half="$1" env="$2"
  mkdir "$work/$half"
  cp "$here/$half.tape" "$here/shell.sh" "$here/vat-return.mjs" "$work/$half/"
  (
    set -a
    # shellcheck disable=SC1090
    . "$env"
    set +a
    for name in EKWO_DB_URL SUPABASE_URL SUPABASE_ANON_KEY SUPABASE_SERVICE_ROLE_KEY EKWO_PASSWORD; do
      if [ -z "${!name:-}" ]; then echo "render.sh: $name is not set in $env" >&2; exit 2; fi
    done
    cd "$work/$half" && vhs -q "$half.tape"
  )
}
record gb "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")" &
left=$!
record ee "$(cd "$(dirname "$2")" && pwd)/$(basename "$2")" &
right=$!
wait "$left"
wait "$right"

for half in gb ee; do
  # vhs writes the text and the cursor as two layers of frames; lay one on
  # the other, and give the terminal a margin in its own background colour.
  frames="$work/$half/$half-frames"
  ffmpeg -y -loglevel error \
    -framerate 25 -i "$frames/frame-text-%05d.png" \
    -framerate 25 -i "$frames/frame-cursor-%05d.png" \
    -filter_complex "[0:v][1:v]overlay,pad=iw+48:ih+48:24:24:color=0x0f1114,format=yuv420p" \
    -c:v libx264 -crf 20 "$work/$half.mp4"
done

# Side by side, the shorter half holding its last frame until the longer ends.
longest=0
for half in gb ee; do
  d="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$work/$half.mp4")"
  longest="$(echo "$d $longest" | awk '{ print ($1 > $2) ? $1 : $2 }')"
done
ffmpeg -y -loglevel error -i "$work/gb.mp4" -i "$work/ee.mp4" -filter_complex \
  "[0:v]tpad=stop_mode=clone:stop_duration=600,pad=iw+4:ih:0:0:color=0x30363d[l];[1:v]tpad=stop_mode=clone:stop_duration=600[r];[l][r]hstack=inputs=2,trim=duration=$longest,format=yuv420p[v]" \
  -map "[v]" -c:v libx264 -crf 23 -preset slow -movflags +faststart "$here/install.mp4"

# The README's GIF: the same recording at two and a half times the speed,
# smaller and slower to refresh, under 5 MB.
ffmpeg -y -loglevel error -i "$here/install.mp4" -filter_complex \
  "setpts=PTS/2.5,fps=5,scale=1100:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=32:stats_mode=diff[p];[b][p]paletteuse=dither=none:diff_mode=rectangle" \
  "$here/install.gif"

rm -rf "$work"
ls -l "$here/install.mp4" "$here/install.gif"
