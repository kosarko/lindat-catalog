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

while getopts ":u:cb" opt; do
        case ${opt} in
                u ) URL="$OPTARG"
                        ;;
                c ) COMMIT=true
                        ;;
                b ) BUILD=true
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

URL="${URL:-http://localhost:8983/solr/blacklight-core}"

SRC_DIR="$1"
shift

echo "Feeding $URL with data from $SRC_DIR" 1>&2

find "$SRC_DIR" -type f -name '*.xml' -print0 | xargs -0 -n 1 -P "$CPUS" -I filename curl "$URL/update" -H "Content-Type: text/xml" --data-binary @filename

if $COMMIT; then
  curl "$URL/update" -H "Content-Type: text/xml" --data-binary '<commit softCommit="true" />'
fi

if $BUILD; then
  curl "$URL/suggest?suggest.build=true"
fi






