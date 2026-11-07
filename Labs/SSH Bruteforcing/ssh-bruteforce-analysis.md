# SSH Brute Force Attack Analysis

Author: Gresa Hisa

---

## Overview

Forensic investigation of a high-volume SSH brute-force attack targeting a CentOS server. The analysis covers log extraction, username enumeration, cross-referencing with system accounts, attack interpretation, and hardening recommendations.

All commands were executed in Kali Linux against provided CentOS authentication logs.

---

## Environment

| Item | Detail |
|---|---|
| Analysis OS | Kali Linux |
| Target system | CentOS |
| Log format | secure, secure-20240804 |
| Tools used | grep, awk, sort, uniq, bash |

---

## Scope

- Username extraction from failed SSH authentication events
- Invalid user identification
- Cross-reference with /etc/passwd
- Attack pattern interpretation
- Security hardening recommendations
- Continuous monitoring strategy

---

## 1. Log Preparation

Navigate to log directory:

```bash
cd ~/Downloads/bruteforce/securelogs
ls
```

Expected output:
```
secure
secure-20240804
```

---

## 2. Extract Valid Usernames (Failed Login Attempts)

Extract all usernames from failed SSH login events targeting existing accounts:

```bash
grep "Failed password for" secure* | grep -v "invalid user" | awk '{print $9}' > usernames.log
cat usernames.log
```

**Result:** Multiple brute-force attempts targeting `root`. Indicates privilege escalation intent.

---

## 3. Extract Invalid Usernames (Non-Existent Accounts)

```bash
grep "Invalid user" secure* | awk '{print $8}' | sort -u > abc.txt
cat abc.txt
```

**Result:** Hundreds of random usernames including:
```
tom
ubuntu
uniadmin
zookeeper
oracle
ftpuser
root1
uftp
...
```

Pattern confirms automated botnet activity using a large username dictionary.

---

## 4. Cross-Reference With System Accounts

Create the cross-reference script:

```bash
nano testtheusers_1.sh
```

Script contents:

```bash
#!/bin/bash
while read user; do
    if grep -q "^$user:" /etc/passwd; then
        echo "EXISTS: $user"
    else
        echo "NOT FOUND: $user"
    fi
done < abc.txt
```

Make executable and run:

```bash
chmod +x testtheusers_1.sh
./testtheusers_1.sh
```

**Result:** All usernames returned `NOT FOUND`. Only `root` exists as a real system account.

---

## 5. Additional Analysis Commands

Count total failed brute-force attempts:

```bash
grep -i "Failed password" secure* | wc -l
```

Show attacker IPs:

```bash
grep "Failed password for" secure* | awk '{print $11}' | sort -u
```

Show login attempt frequency per username:

```bash
grep "Failed password" secure* | awk '{print $9}' | sort | uniq -c
```

Show all failed SSH login lines:

```bash
grep -i "failed" secure*
```

---

## 6. Attack Interpretation

| Indicator | Finding |
|---|---|
| Attack type | High-volume automated SSH brute force |
| Primary target | root (privilege escalation motive) |
| Username source | Large dictionary — matches global botnet behavior |
| Internal accounts compromised | None |
| Attack origin | External, fully automated |
| Severity | HIGH |

---

## 7. Security Hardening Recommendations

The following configurations are for documentation only and were not executed on the analyzed system.

**Disable root SSH login** (`/etc/ssh/sshd_config`):
```
PermitRootLogin no
```

**Disable password authentication** (SSH keys only):
```
PasswordAuthentication no
```

**Enable Fail2Ban** — automatically blocks IPs after repeated failures.

**Restrict SSH to trusted IPs** — firewall rules to limit access.

**Change default SSH port** — reduces noise from automated scanners.

**Enable MFA for SSH** — adds an additional authentication layer.

Restart SSH service after changes:
```bash
sudo systemctl restart sshd
```

---

## 8. Continuous Monitoring Recommendations

- Implement log monitoring with Splunk, ELK, or Logwatch
- Enable alerts on repeated authentication failures
- GeoIP lookup for suspicious attacker IPs
- Monitor SSH access patterns and reputation-check IPs
- Perform regular SSH configuration audits
- Weekly security reports

---

## Conclusion

This investigation confirms a large-scale external SSH brute-force attack. The attacker used an automated botnet with a large username dictionary, targeting primarily `root` for privileged access. No internal accounts were compromised. The attack is classified as high-severity due to its volume and direct targeting of the root account.

The analysis demonstrates proficiency in log forensics, bash scripting, SSH threat analysis, and security hardening methodology.
