#!/bin/sh

set -e -o pipefail
umask 077

die() {
    echo "[!] $*";
    exit 255
}

log() {
    echo "[-] $*"
}

config_interface() {
    ER_IFACE=$(ip route|grep ${ER_SUBNET}| cut -d' ' -f3)
    ER_PRIVATEKEY="$(cat ${ER_KEYFILE})"
    cat << EOF >/etc/wireguard/wg0.conf
[Interface]
Address = ${ER_ADDRESS}
ListenPort = ${ER_PORT}
PrivateKey = ${ER_PRIVATEKEY}
PostUp = iptables -A FORWARD -i %i -j ACCEPT;iptables -t nat -A POSTROUTING -o ${ER_IFACE} -j MASQUERADE;iptables -A FORWARD -o %i -j ACCEPT
PostDown = iptables -D FORWARD -i %i -j ACCEPT;iptables -t nat -D POSTROUTING -o ${ER_IFACE} -j MASQUERADE;iptables -D FORWARD -o %i -j ACCEPT

EOF
}

add_peer() {
    cat << EOF >>/etc/wireguard/wg0.conf
[Peer]
# host is $3
PublicKey = $1
AllowedIPs = $2

EOF

    log "Added peer $2 ($3)"
}

check_env() {
    local check;
    local need_die;
    need_die=false;
    check="ER_ADDRESS ER_PORT ER_KEYFILE ER_PEERS ER_SUBNET"
    for e in ${check}
    do
        if [[ -z "$(eval echo \${${e}})" ]]; then
            log "Environment variable ${e} not set"
            need_die=true
        fi
    done
    if $need_die ; then
        die "...unable to continue"
    fi
    log "..variables ok"

}

check_files() {
    local check;
    local need_die;
    need_die=false;
    check="${ER_KEYFILE} ${ER_PEERS}"
    for f in ${check}
    do
        if [[ ! -e "${f}" ]]; then
            log "File ${f} not exist"
            need_die=true
        fi
    done
    if $need_die ; then
        die "File not found"
    fi
    log "..files ok"
}

add_peers() {
    local key
    local ip
    while IFS=' ' read -r key ip hostid || [ -n "${l}" ]
    do
        add_peer ${key} ${ip} ${hostid}
    done < ${ER_PEERS}
}

log "Starting checks"
check_env
check_files

log "Configuring interface"
config_interface
log "Adding peers"
add_peers


if [[ "x$1" == "xrun" ]]; then
    log "Starting up interface"
    wg-quick up wg0
    forrest=true
    trap forrest=false 2 3 6 15
    while ${forrest}
    do
        sleep 5
    done
    log "Tearing down"
    wg-quick down wg0
else
    log "Executing custom command"
    exec $@
fi
