# Ethical Hacking: Reconnaissance, Footprinting & Scanning

**Target:** securedefense.ch

---

Author: Gresa Hisa

---

## Objective

Perform a structured reconnaissance and early-stage penetration test against a legally owned target. The goal is to map the attack surface using WHOIS, DNS enumeration, OSINT, subdomain discovery, and Nmap scanning. All activities were conducted against a student-owned domain within defined scope.

---

## Scope

- WHOIS profiling
- DNS and DNSSEC validation
- OSINT dorking
- Subdomain enumeration
- Recon-ng automation
- Nmap TCP/version scanning
- Attack surface analysis

---

## 1. WHOIS Intelligence

**Command:**
```
whois securedefense.ch
```

**Findings:**

| Field | Value |
|---|---|
| Registrar | Hostpoint AG (CH) |
| Nameservers | Cloudflare (gracie, ed) |
| DNSSEC | Not enabled |
| First Registration | 18 Nov 2025 |

**Interpretation:**  
Cloudflare is correctly masking origin infrastructure. No registry-level information leakage detected.

---

## 2. DNS Enumeration

### A/AAAA Records
```
nslookup securedefense.ch
```
Returned Cloudflare IPv4 and IPv6 edge proxies. No backend IP leakage.

### ANY Lookup
```
dig securedefense.ch ANY
```
Only NS and A records returned. No misconfigured zones detected.

### AXFR Attempt
```
dig AXFR securedefense.ch @ed.ns.cloudflare.com
```
Zone transfer correctly blocked.

---

## 3. OSINT Exposure Check

**Google dorks used:**
```
site:securedefense.ch
site:securedefense.ch inurl:login
site:securedefense.ch "index of"
site:securedefense.ch ext:sql
site:securedefense.ch ext:env
"@securedefense.ch"
```

**Result:**  
No exposed admin panels, sensitive files, or email leaks found. Attack surface is minimal.

---

## 4. Subdomain Enumeration

Tools used: nslookup, dig, Cloudflare DNS, recon-ng

**Recon-ng module:**
```
recon/domains-hosts/google_site_web
```

**Result:**  
Zero public subdomains discovered. No shadow assets present.

---

## 5. Nmap Scanning

**Command:**
```
nmap 104.21.89.140
```

**Open Ports:**

| Port | Service | Notes |
|---|---|---|
| 80 | HTTP | Cloudflare proxy |
| 443 | HTTPS | Cloudflare TLS termination |
| 8080 | HTTP alt | Cloudflare endpoint |
| 8443 | HTTPS alt | Cloudflare endpoint |

**Aggressive Scan:**
```
nmap -A securedefense.ch
```

- OS detection not possible behind Cloudflare
- Traceroute terminates at Cloudflare edge
- No origin server fingerprinting possible

**Interpretation:**  
Origin server is fully shielded. Security posture is correct.

---

## 6. Security Assessment Summary

### Strengths

- Cloudflare WAF, proxy, and DDoS protection active
- No OSINT exposure
- No exposed subdomains
- DNS zone transfer blocked
- Standard ports only
- Origin IP hidden
- Clean, low-risk footprint

### Weaknesses and Recommendations

| Finding | Recommendation |
|---|---|
| DNSSEC disabled | Enable DNSSEC for DNS integrity validation |
| Missing security headers | Implement HSTS, CSP, X-Frame-Options |
| Cloudflare features unused | Enable Bot Fight Mode, rate limiting, WAF rules, Zero Trust policies |

---

## Conclusion

The reconnaissance assessment confirms that securedefense.ch is hardened, minimal, and well-protected. The domain operates behind Cloudflare, exposes only edge nodes, leaks no sensitive OSINT, blocks DNS zone transfers, and maintains a small attack surface.

**Skills demonstrated:**

- Footprinting and OSINT
- DNS and WHOIS intelligence gathering
- Subdomain enumeration
- Nmap network scanning
- Recon-ng automation
- Attack surface analysis
