#!/bin/bash
# Author: Gresa Hisa
# VAPT commands used against VulnVMa (192.168.1.233)
# All tests performed in a controlled VirtualBox lab environment

TARGET="192.168.1.233"

# 1. Reconnaissance
nmap -sV -sC $TARGET

# 2. Directory brute force
gobuster dir -u http://$TARGET -w /usr/share/wordlists/dirb/common.txt

# 3. robots.txt extraction
curl http://$TARGET/robots.txt

# 4. Hidden admin panel (manual browser inspection)
# http://$TARGET/4dm1n/
# View source for HTML comments

# 5. Config page
curl http://$TARGET/Config/

# 6. Burp Suite — POST to admin login
# Configure Firefox proxy: 127.0.0.1:8080
# Submit any credentials to http://$TARGET/4dm1n/login
# Intercept POST response in Burp Suite
