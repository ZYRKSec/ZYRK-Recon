⚡ 60-Second Demo
bash
Copy
chmod +x infinity-recon.sh
./infinity-recon.sh
# Enter target IP → grab coffee → harvest filtered intel
🎯 What It Does
Table
Copy
Phase	Tool / Technique	Purpose
AI Word-List	Gemma-3n 4B (OpenRouter free)	90 target-specific paths generated from live open ports
Network Mapping	nmap -sS -sV -T4	SYN stealth + service version detection at turbo speed
Content Discovery	gobuster	Cloudflare-evade headers + status filter → only 2xx/3xx hits captured
Tech Fingerprint	whatweb -a3	Framework, CDN, SSL & proxy leaks for next-step exploitation
🧪 Sample Output (Cloudflare Target)
Copy
[+] AI word-list 4311 lines → scan-1767.../wordlist.txt  
[+] nmap: 12 open ports  
[+] gobuster https://104.18.36.214:443  hits (2xx/3xx): 0  
[+] tech: 47 lines  
scan complete → scan-1767...
Zero positives = hardened perimeter documented; pipeline validated.
🛠️ Prerequisites
bash, nmap, gobuster, whatweb, python3, curl
OpenRouter API key (free tier sufficient)
🔐 API Key Setup
bash
Authorization": "Bearer enter_your_openrouter_api_key_here
📊 Public Logs
Every run commits live metrics → GitHub Logs Folder
Commit hash = scan timestamp → 100% reproducible.
🤝 Contributing
PRs welcome:
Additional AI providers
CDN-specific bypass modules
JSON / SARIF export for CI pipelines
📜 License
MIT

Built by SyedSec | ZYRKSec
“Autonomous offense, transparent results.

