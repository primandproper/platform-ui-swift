#!/usr/bin/env bash
# Print the UDID of an iPhone simulator on the newest installed iOS runtime, so builds follow
# whatever Xcode the machine has rather than naming a device one version ships and the next drops.
set -euo pipefail

device="$(xcrun simctl list devices available --json | jq -r '
  .devices
  | to_entries
  | map(select(.key | test("SimRuntime\\.iOS-")))
  | sort_by(.key | capture("iOS-(?<v>[0-9-]+)").v | split("-") | map(tonumber))
  | map(.value[] | select(.name | startswith("iPhone")))
  | last
  | .udid // empty')"

if [[ -z "$device" ]]; then
  echo "no available iPhone simulator; install an iOS runtime in Xcode" >&2
  exit 1
fi

echo "$device"
