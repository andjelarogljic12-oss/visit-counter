#!/usr/bin/env bash
# Proverava da li aplikacija radi pozivanjem /health endpoint-a.
# Upotreba: ./healthcheck.sh http://localhost:8080

if [ -z "$1" ]; then
  echo "Upotreba: $0 <URL>"
  echo "Primer:   $0 http://localhost:8080"
  exit 1
fi

URL="$1"
MAX_ATTEMPTS=5
PAUSE=3

for i in $(seq 1 "$MAX_ATTEMPTS"); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL/health")
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Pokušaj $i/$MAX_ATTEMPTS – HTTP $CODE"

  if [ "$CODE" = "200" ]; then
    echo "Aplikacija je zdrava."
    exit 0
  fi

  if [ "$i" -lt "$MAX_ATTEMPTS" ]; then
    sleep "$PAUSE"
  fi
done

echo "Aplikacija nije zdrava ni posle $MAX_ATTEMPTS pokušaja."
exit 1
