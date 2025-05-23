#!/bin/bash

set -e

# Description mappings for HTTP status codes
declare -A STATUS_DESCRIPTIONS=(
  [200]="OK"
  [301]="Moved Permanently"
  [302]="Found"
  [400]="Bad Request"
  [401]="Unauthorized"
  [403]="Forbidden"
  [404]="Not Found"
  [500]="Internal Server Error"
  [502]="Bad Gateway"
  [503]="Service Unavailable"
)

function get_status_description() {
  local code=$1
  echo "${STATUS_DESCRIPTIONS[$code]:-Unknown Status Code}"
}

function scan_ip() {
  local ip=$1
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local outdir="/output/${ip}_${timestamp}"
  mkdir -p "$outdir"

  echo "[+] Scanning IP: $ip"

  echo "[*] GET / on $ip" | tee "$outdir/http_headers.txt"
  response=$(curl -s -o "$outdir/root_response_body.html" -w "%{http_code}" --max-time 5 http://$ip/)
  description=$(get_status_description $response)
  echo "Status Code: $response ($description)" >> "$outdir/http_headers.txt"

  declare -a paths=("/admin" "/login" "/.env" "/.git" "/config" "/debug" "/server-status")
  echo -e "\n[*] Scanning sensitive paths..." >> "$outdir/sensitive_paths.txt"
  for path in "${paths[@]}"; do
    full_url="http://$ip$path"
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$full_url")
    desc=$(get_status_description $code)
    echo "$full_url => $code ($desc)" >> "$outdir/sensitive_paths.txt"
  done

  echo "[*] Checking for HTTPS certificate..." | tee "$outdir/https_cert.txt"
  timeout 5 bash -c "echo | openssl s_client -connect $ip:443 -servername $ip 2>/dev/null | openssl x509 -noout -subject -issuer -dates" >> "$outdir/https_cert.txt" || echo "No certificate found or timeout." >> "$outdir/https_cert.txt"
}

function scan_cidr() {
  local cidr=$1
  echo "[+] Scanning CIDR block: $cidr"
  mapfile -t hosts < <(nmap -sn "$cidr" | grep "Nmap scan report for" | awk '{print $5}')
  for host in "${hosts[@]}"; do
    scan_ip "$host"
  done
}

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <IP_ADDRESS | CIDR_RANGE>"
  exit 1
fi

target=$1
if [[ "$target" =~ "/" ]]; then
  scan_cidr "$target"
else
  scan_ip "$target"
fi
