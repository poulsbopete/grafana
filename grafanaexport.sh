#!/bin/bash

set -o errexit
set -o pipefail
set -x

FULLURL="$HOST"
headers="Authorization: Bearer $APIKEY"
in_path=dashboards_raw
set -o nounset

echo "Exporting Grafana dashboards from $FULLURL"
mkdir -p $in_path
for dash in $(curl -H "$headers" -s "$FULLURL/api/search?query=&" | jq -r '.[] | select(.type == "dash-db") | .uid'); do
        dash_path="$in_path/$dash.json"
        curl -H "$headers" -s "$FULLURL/api/dashboards/uid/$dash" | jq -r . > $dash_path
        slug=$(cat $dash_path | jq -r '.meta.slug')
        folder="$(cat $dash_path | jq -r '.meta.folderTitle')"
        mkdir -p "$folder"
        mv -f $dash_path $folder/${dash}-${slug}.json
done