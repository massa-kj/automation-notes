#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: create_year_dirs.sh -y YEAR [-d month|day] [-s SEPARATOR]

Options:
  -y YEAR        Target year (e.g. 2026)
  -d DEPTH       Depth to create: month or day (default: month)
  -s SEPARATOR   Separator between date parts (default: none)
  -h             Show this help

Examples:
  ./create_year_dirs.sh -y 2026
  ./create_year_dirs.sh -y 2026 -d day
  ./create_year_dirs.sh -y 2026 -s '-'
  ./create_year_dirs.sh -y 2026 -d day -s '-'
USAGE
}

YEAR=""
DEPTH="month"
SEP=""

while getopts ":y:d:s:h" opt; do
  case "$opt" in
    y) YEAR="$OPTARG" ;;
    d) DEPTH="$OPTARG" ;;
    s) SEP="$OPTARG" ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$YEAR" ]]; then
  echo "Error: -y YEAR is required." >&2
  usage >&2
  exit 1
fi

if ! [[ "$YEAR" =~ ^[0-9]{4}$ ]]; then
  echo "Error: YEAR must be 4 digits." >&2
  exit 1
fi

if [[ "$DEPTH" != "month" && "$DEPTH" != "day" ]]; then
  echo "Error: -d must be 'month' or 'day'." >&2
  exit 1
fi

ensure_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    echo "skip: $path"
  else
    mkdir -p "$path"
    echo "create: $path"
  fi
}

YEAR_DIR="$YEAR"
ensure_dir "$YEAR_DIR"

if [[ "$DEPTH" == "month" ]]; then
  for month in {01..12}; do
    month_dir="$YEAR_DIR/${YEAR}${SEP}${month}"
    ensure_dir "$month_dir"
  done
  exit 0
fi

start_date="${YEAR}-01-01"
end_date="${YEAR}-12-31"

current="$start_date"
while [[ "$current" != "$(date -d "$end_date" +%F)" ]]; do
  y=$(date -d "$current" +%Y)
  m=$(date -d "$current" +%m)
  d=$(date -d "$current" +%d)

  month_dir="$YEAR_DIR/${y}${SEP}${m}"
  day_dir="$month_dir/${y}${SEP}${m}${SEP}${d}"

  ensure_dir "$month_dir"
  ensure_dir "$day_dir"

  current=$(date -d "$current + 1 day" +%F)
done

# handle end_date
final_y=$(date -d "$end_date" +%Y)
final_m=$(date -d "$end_date" +%m)
final_d=$(date -d "$end_date" +%d)
final_month_dir="$YEAR_DIR/${final_y}${SEP}${final_m}"
final_day_dir="$final_month_dir/${final_y}${SEP}${final_m}${SEP}${final_d}"
ensure_dir "$final_month_dir"
ensure_dir "$final_day_dir"
