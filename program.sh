#! /usr/bin/env bash
# /*
# Exit on failure; treat any failure in a pipe as the failure of the whole pipe
set -eo pipefail

function log () {
  return 0
  echo "$@" 1>&2
}

log started

THIS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
BUILT="#{built}"

function html_escape () {
  echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

function template_replace_sed () {
  local template="$1"
  # assumed to be a resonable word-only string like "dog"
  local key="$2"
  # Escape sed special chars from the value, so we can use it safely
  local value="$(echo "$3" | sed -e 's/[\/&\
]/\\&/g')"
  echo "$template" | sed 's/#{'"$key"'}/'"$value"'/g'
}

function template_replace_bash () {
  local template="$1"
  local key="$2"
  local value="$3"

  log "Replacing $key"

  local search='#{'"$key"'}'
  echo "${template//$search/$value}"

  log "Done: $key"
}

function render () {
  local template="$1"
  shift

  # while this function still has arguments
  while (( "$#" )); do
    local key="$1"
    local value="$2"
    template="$(template_replace_bash "$template" "$key" "$value")"
    log "$template"
    shift 2
  done

  echo "$template"
}

function main () {
  ## Initial plan
  # 1. read STDIN somehow
  input="$(< "${1:-/dev/stdin}")"
  log "read input"

  # 2. Create a .html file by combining a template with STDIN data
  #     read: bash builtin that reads from its STDIN into a variable
  #       -r: raw
  #    -d '': read with no delimiter; so it will read all of its STDIN instead of
  #           just a line at a time.
  # template: name of variable to read into
  #  <<"EOF": Start of a "heredoc", a bash construct that sends the given
  #           multi-line string to STDIN of the process. Heredocs with a quoted
  #           delimiter, like this one, don't process parameter expansion (like
  #           $() or ${}).
  #  {html}: bulman template marker -- will be replaced during build process
  #          with actual HTML.
  # || true: read returns non-zero (aka an error) at EOF; so without || true,
  #          the set -e causes our program to exit!
  read -r -d '' template <<"EOF" || true
#{html}
EOF
  log "read template"
  output="$(render "$template" content "$(html_escape "$input")" styles_path "$THIS_FILE")"
  log "made output"
  tmpdir="$(mktemp -dt bulman)"
  log "made tempdir"
  html_file="${tmpdir}/index.html"
  echo -n "${output}" > "${html_file}"
  log "wrote outpute"

  # 3. call `open -a ...` to open the user's browser to view the file
  open "${html_file}"
  log "done."
}

# Print to STDOUT the compiled version of this script
# $1 - HTML template path
# $2 - CSS path
# $3 - Javascript path
build_self () {
  template=$(< "$THIS_FILE")
  render "$template" \
    html "$(< "$1")" \
    javascript "$(< "$3")" \
    built true \
    styles "$(< "$2")"
}

if [ "$BUILT" == true ]; then
  log main
  main
else
  build_self "$1" "$2" "$3"
fi

exit 0

# */

#{styles}
