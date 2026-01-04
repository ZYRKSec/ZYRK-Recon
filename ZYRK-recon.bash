#!/usr/bin/env bash
# Infinity-Recon FINAL – Gemma-3n AI + nmap -sV -T4 + gobuster + tech
set -euo pipefail

read -rp "Enter target IP / hostname: " TARGET
OUT="scan-$(date +%s)_${TARGET}"
mkdir -p "$OUT"
WORDLIST="$OUT/wordlist.txt"
CAPTURE="$OUT/capture.txt"
TECH="$OUT/tech.txt"

# 1. Gemma-3n (OpenRouter) AI word-list -----------------------
python3 - "$TARGET" "$WORDLIST" <<'PY'
import random, string, requests, subprocess, sys
T, O = sys.argv[1], sys.argv[2]
ports = subprocess.check_output(
    f"nmap -sS -T5 --open -p 80,443,8080,8443,8880 {T} 2>/dev/null | grep -oP '\\d+(?=/open)' || true",
    shell=True, text=True).strip().split()
salt = ''.join(random.choices(string.ascii_lowercase, k=6))
prompt = f"Target {T} open ports {','.join(ports)}. Give 90 unique web paths attackers love. Add 5 random like {salt}. One per line."
wl = set()
try:
    r = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers={
            "Authorization": "Bearer enter_your_openrouter_api_key_here",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://localhost",
            "X-Title": "infinity-recon"
        },
        json={"model": "google/gemma-3n-e4b-it:free", "messages": [{"role": "user", "content": prompt}], "temperature": 0.98},
        timeout=30
    ).json()
    txt = r["choices"][0]["message"]["content"]
    wl = {w.strip().lower() for w in txt.splitlines() if len(w.strip()) > 2}
except Exception as e:
    print("[-] AI failed:", e)
if len(wl) < 80:
    with open("/usr/share/wordlists/dirb/common.txt", errors="ignore") as f:
        wl.update(w.strip() for w in f if len(w.strip()) > 2)
with open(O, "w") as f:
    f.write("\n".join(sorted(wl)[:90]))
print(f"[+] AI word-list {len(wl)} lines → {O}")
PY

# 2. nmap -sV -T4 -------------------------------------------
echo "[+] nmap scanning ..."
nmap -sS -T4 -sV --open -p- -oG "$OUT/nmap.gnmap" "$TARGET" 2>/dev/null
grep -oP '\d+(?=/open)' "$OUT/nmap.gnmap" | sort -un > "$OUT/ports.txt"
echo "[+] nmap: $(wc -l < "$OUT/ports.txt") open ports"

# 3. gobuster (LOUD & CLEAR, keep 200-399)
echo "[+] starting gobuster ..."
for p in 80 443 8080 8443 8880; do
  grep -qx "$p" "$OUT/ports.txt" || continue
  for proto in http https; do
    url="$proto://$TARGET:$p"
    curl -ksm5 -H "User-Agent: InfinityRecon/1.0" "$url" >/dev/null 2>&1 || continue
    out="$OUT/gobuster_${proto}_${p}.txt"
    echo "[+] gobuster $url ..."
    # --- quiet removed, errors only suppressed ----
    gobuster dir -u "$url" -w "$WORDLIST" -o "$out" \
          -H "User-Agent: InfinityRecon/1.0" -b 404,403,400,500,502,503 2>/dev/null || true
    # count 2xx/3xx lines (gobuster shows  /path   (status: 200)  )
    hits=$(grep -Ecv 'Status: (404|403|400|500|502|503|429)' "$out" 2>/dev/null || echo 0)
    echo "[+] $url  hits (2xx/3xx): $hits"
    grep -Ev 'Status: (404|403|400|500|502|503|429)' "$out" 2>/dev/null >> "$CAPTURE"
  done
done
echo "[+] total gobuster hits: $(wc -l < "$CAPTURE")"

# 4. tech (whatweb) -----------------------------------------
echo "[+] whatweb ..."
for p in 80 443 8080 8443 8880; do
  grep -qx "$p" "$OUT/ports.txt" || continue
  for proto in http https; do
    whatweb -a3 "$proto://$TARGET:$p" 2>/dev/null >> "$TECH"
  done
done
echo "[+] tech: $(wc -l < "$TECH") lines"

echo; echo "scan complete → $OUT"
