# Vulnerability Assessment and Penetration Testing: Simulated Web Application

Author: Gresa Hisa

---

## Overview

A vulnerable web application (VulnVMa) was deployed in a controlled VirtualBox environment and assessed using Kali Linux. The objective was to identify security misconfigurations, perform reconnaissance, exploit exposed services, and extract hidden flags representing sensitive data leaks. All six flags were successfully captured.

---

## Environment

| Item | Detail |
|---|---|
| Target VM | VulnVMa |
| Target IP | 192.168.1.233 |
| Attacker machine | Kali Linux (VirtualBox) |
| Tools | Nmap, Gobuster, cURL, Firefox, Burp Suite Community Edition |

---

## Methodology

### 1. Reconnaissance

```bash
nmap -sV -sC 192.168.1.233
```

**Findings:**

| Port | Service | Notes |
|---|---|---|
| 21 | vsftpd 3.0.5 | Anonymous access enabled — misconfigured |
| 22 | OpenSSH 8.9p1 | Standard SSH |
| 80 | Apache 2.4.52 | Hosts vulnerable "Travel Blog" application |

---

### 2. Directory Enumeration

```bash
gobuster dir -u http://192.168.1.233 -w /usr/share/wordlists/dirb/common.txt
```

**Discovered directories:** `/css`, `/images`, `/js`, `/pages`, `/4dm1n`, `/phpinfo`, `/Config`

---

### 3. robots.txt Extraction

```bash
curl http://192.168.1.233/robots.txt
```

**Result:** Exposed hidden paths and Flag 2.

```
flag 2 -> 930f04eb6ff0eb8664b2157dd2aa048c6
```

---

### 4. Hidden Admin Panel

Navigated to disguised admin directory:

```
http://192.168.1.233/4dm1n/
```

Inspecting page source revealed Flag 4 inside an HTML comment:

```html
<!-- Flag 4 -> 337651bfdec655e80334648eae68ac3c -->
```

---

### 5. Configuration Page Exposure

```
http://192.168.1.233/Config/
```

Exposed PHP configuration details, system paths, version numbers, and Flag 5:

```
flag 5 -> 88615e277ae89ad96a4a365a9a854740
```

**Severity:** Critical — direct information disclosure of system-level configuration.

---

### 6. Burp Suite Interception

Configured Burp Suite to proxy Firefox traffic. Submitted arbitrary credentials to the admin login:

```
POST /4dm1n/login HTTP/1.1
Host: 192.168.1.233
Content-Type: application/x-www-form-urlencoded

username=test&password=test
```

POST response leaked Flag 6:

```
flag 6 -> 0b318d8bf0d5b38c6d38ede5e2af71c3
```

Demonstrates insecure error handling and improper response sanitization.

---

## Flags Captured

| Flag | Location | Method |
|---|---|---|
| Flag 2 | /robots.txt | cURL |
| Flag 4 | /4dm1n/ HTML source | Manual inspection |
| Flag 5 | /Config/ | Direct URL access |
| Flag 6 | POST /4dm1n/login response | Burp Suite interception |

---

## Vulnerabilities Identified

### Anonymous FTP Enabled
Port 21 configured for anonymous access. Dangerous if directory permissions are loosened.

### Sensitive Information in robots.txt
robots.txt exposed hidden admin paths — the opposite of its intended purpose.

### HTML Comment Disclosure
Flag embedded directly in HTML source code — developer debug artifact left in production.

### Exposed PHP Configuration Page
`/Config/` accessible without authentication, revealing system version, environment paths, and internal configuration.

### Insecure Login Error Handling
POST response to `/4dm1n/login` leaks sensitive data on failed authentication. No server-side sanitization.

---

## Recommendations

| Finding | Fix |
|---|---|
| Anonymous FTP | Disable entirely |
| robots.txt exposure | Remove sensitive path entries |
| Admin endpoint | Rename, restrict, require authentication |
| HTML comments | Strip all debug/flag data before deployment |
| Config page | Block public access to phpinfo() and config pages |
| Login handler | Enforce server-side input validation and generic error responses |

---

## Conclusion

All key objectives were met. Reconnaissance, enumeration, manual inspection, and traffic interception successfully identified multiple misconfigurations and extracted four flags. The assessment confirms the application is insecure with unauthorized access pathways and information leakage across multiple attack vectors.
