# Sourced by the tapes, off camera. Not part of Ekwo: it only keeps the
# recording free of anything that identifies the project it was made on.
#
# Needs, from the environment render.sh was started in: EKWO_DB_URL,
# SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY and
# EKWO_PASSWORD (the password of the administrator the tape creates).

PS1="\[\e[38;5;245m\]${DEMO_LABEL:-ekwo} \$\[\e[0m\] "
export EKWO_CONFIG_DIR="$PWD/.ekwo-config"

# Every `npx` on camera runs through a terminal of its own, so the colours
# stay, and through sed, so the project reference and the working directory
# never reach the frame. render.sh has fetched the release beforehand, so
# both halves find it in the cache. The command typed is the command run.
__ekwo_ref="${SUPABASE_URL#https://}"
__ekwo_ref="${__ekwo_ref%%.*}"
__ekwo_npx="$(command -v npx)"
npx() {
  script -q /dev/null "$__ekwo_npx" --yes "$@" \
    | sed -e "s#${__ekwo_ref}#<project-ref>#g" -e "s#/private${PWD}#.#g" -e "s#${PWD}#.#g"
}
