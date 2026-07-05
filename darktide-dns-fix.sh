#!/bin/bash
set -euo pipefail

HOSTS_FILE="/etc/hosts"
MARKER_START="# BEGIN darktide-dns-fix"
MARKER_END="# END darktide-dns-fix"

SERVERS=(
  echo-prod-aws-af-south-1.atoma.cloud
  echo-prod-aws-ap-east-1.atoma.cloud
  echo-prod-aws-ap-northeast-1.atoma.cloud
  echo-prod-aws-ap-northeast-2.atoma.cloud
  echo-prod-aws-ap-south-1.atoma.cloud
  echo-prod-aws-ap-southeast-1.atoma.cloud
  echo-prod-aws-ap-southeast-2.atoma.cloud
  echo-prod-aws-ca-central-1.atoma.cloud
  echo-prod-aws-eu-central-1.atoma.cloud
  echo-prod-aws-eu-north-1.atoma.cloud
  echo-prod-aws-eu-west-1.atoma.cloud
  echo-prod-aws-eu-west-2.atoma.cloud
  echo-prod-aws-me-south-1.atoma.cloud
  echo-prod-aws-sa-east-1.atoma.cloud
  echo-prod-aws-us-east-1.atoma.cloud
  echo-prod-aws-us-east-2.atoma.cloud
  echo-prod-aws-us-west-2.atoma.cloud
  echo-prod-ga-aws-af-south-1.atoma.cloud
  echo-prod-ga-aws-ap-east-1.atoma.cloud
  echo-prod-ga-aws-ap-northeast-1.atoma.cloud
  echo-prod-ga-aws-ap-northeast-2.atoma.cloud
  echo-prod-ga-aws-ap-southeast-1.atoma.cloud
  echo-prod-ga-aws-ap-southeast-2.atoma.cloud
  echo-prod-ga-aws-ca-central-1.atoma.cloud
  echo-prod-ga-aws-eu-central-1.atoma.cloud
  echo-prod-ga-aws-eu-north-1.atoma.cloud
  echo-prod-ga-aws-eu-west-1.atoma.cloud
  echo-prod-ga-aws-eu-west-2.atoma.cloud
  echo-prod-ga-aws-me-south-1.atoma.cloud
  echo-prod-ga-aws-sa-east-1.atoma.cloud
  echo-prod-ga-aws-us-east-1.atoma.cloud
  echo-prod-ga-aws-us-east-2.atoma.cloud
  echo-prod-ga-aws-us-west-1.atoma.cloud
)

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo." >&2
  exit 1
fi

resolve() {
  local host="$1"
  local ip=""
  ip=$(getent ahostsv4 "$host" 2>/dev/null | awk '{print $1; exit}') || true
  if [ -z "$ip" ] && command -v dig >/dev/null 2>&1; then
    ip=$(dig +short +time=2 +tries=2 A "$host" | grep -E '^[0-9]+\.' | head -1) || true
  fi
  echo "$ip"
}

tmpfile=$(mktemp)
sed "/^${MARKER_START}$/,/^${MARKER_END}$/d" "$HOSTS_FILE" > "$tmpfile"

{
  echo "$MARKER_START"
  for host in "${SERVERS[@]}"; do
    ip=$(resolve "$host")
    if [ -n "$ip" ]; then
      echo "$ip $host"
    fi
  done
  echo "$MARKER_END"
} >> "$tmpfile"

cp "$tmpfile" "$HOSTS_FILE"
rm -f "$tmpfile"
