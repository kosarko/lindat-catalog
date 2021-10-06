#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
export SHELLOPTS

WD=$(dirname "$(readlink -e "$0")")
COMMIT=false
BUILD=false
MTIME=

while getopts ":u:cbm:" opt; do
        case ${opt} in
                u ) URL="$OPTARG"
                        ;;
                c ) COMMIT=true
                        ;;
                b ) BUILD=true
                        ;;
                m ) MTIME="-mtime $OPTARG"
                        ;;
                \? ) echo "Usage: cmd -u solr_core_url -c -b DIR..."
                     exit 1
                        ;;
                : )
                    echo "Invalid option: -$OPTARG requires an argument" 1>&2
                    exit 1
                        ;;
        esac
done
shift $((OPTIND -1))

CPUS=$(nproc)
(( CPUS++ )) || true

export URL="${URL:-http://localhost:8983/solr/blacklight-core}"

SRC_DIR="$1"
shift

echo "Feeding $URL with data from $SRC_DIR" 1>&2

OUT_TMP=$(mktemp -d)
ERR_TMP=$(mktemp -d)

export OUT_TMP ERR_TMP

function curl_send() {
    local full_path="$1"
    local filename
    filename=$(basename "$full_path")
    local out=$OUT_TMP/${filename%.xml}
    local err=$ERR_TMP/$filename
    curl -s "$URL/update" -H "Content-Type: text/xml" --data-binary "@$full_path" > "$out"
    if grep 'name="error"' "$out" > /dev/null; then
      {
        echo "<?xml-stylesheet href='https://lindat.cz/static/error.xsl' type='text/xsl'?>"
        echo "<root>"
        cat "$out" "$full_path" | grep -v "<?xml"
        echo "</root>"
      } > "$err"
    fi
}

function get_err_msg() {
  local p="$1"
  echo -n "$(basename "$p") "
  xmllint --xpath '/root/response/lst[@name="error"]/str[@name="msg"]/text()' "$p"
  echo
}

export -f curl_send get_err_msg


find "$SRC_DIR" -type f $MTIME -name '*.xml' -print0 | pv --null | xargs -0 -n 1 -P "$CPUS" -I filename bash -c "curl_send filename" _

rm -rf "$OUT_TMP"
echo "ERRORS in $ERR_TMP:"
find "$ERR_TMP" -type f -name '*.xml' -print0 | xargs -I{} -n1 --null bash -c "get_err_msg {}" _ \
  | tee >(cut -d" " -f1,3- | awk 'BEGIN{print "<table>"} {printf "<tr>\n<td>\n<a href=" $1 ">" $1 "</a>\n</td>\n<td>"; for(i=2; i<=NF; i++){printf $i FS}; print "</td>\n</tr>"} END{print "</table>"}' >"$ERR_TMP"/index.html) \
  | cut -d" " -f3- | sort | uniq -c | sort -nr | tee "$ERR_TMP"/stats.txt

if $COMMIT; then
  curl "$URL/update" -H "Content-Type: text/xml" --data-binary '<commit softCommit="true" />'
fi

if $BUILD; then
  curl "$URL/suggest?suggest.build=true"
fi






