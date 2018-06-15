#!/bin/bash

set -o errexit
set -o pipefail

fail() {
  >&2 echo "$@"
  exit 1
}

if [ "${TRAVIS_EVENT_TYPE}" != "cron" ]; then
  echo "Not a cron run; exit"
  exit
fi

# Get trigger ID
trigger_id=$(\
  curl -sLf "https://quay.io/api/v1/repository/mtneug/synfig-core/trigger" \
       -H "Authorization: Bearer ${QUAY_ACCESS_TOKEN}" \
    | jq -Mr ".triggers[0].id" 2> /dev/null
)
test "${trigger_id}" != "null" || fail "Repository has no triggers"

# Start trigger
curl -sLf -X "POST" "https://quay.io/api/v1/repository/mtneug/synfig-core/trigger/${trigger_id}/start" \
     -o /dev/null \
     -H "Authorization: Bearer ${QUAY_ACCESS_TOKEN}" \
     -H "Content-Type: application/json" \
     -d "{\"branch_name\": \"master\"}" > /dev/null 2>&1 || fail "Failed to start trigger"
echo "Started trigger"
