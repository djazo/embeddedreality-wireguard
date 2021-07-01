#!/bin/sh

if ! command -v wg >/dev/null ;then
    echo "Install wireguard tools"
    exit 1
fi

umask 077
# $1 subnet, $2- hosts
subnet=$(echo $1 | cut -d. -f 1-3)
startip=$(echo $1 | cut -d. -f 4)
shift
ip=${startip}
for f in $@
do
    wg genkey | tee $f.key | wg pubkey > $f.pub
    echo "$(cat ${f}.pub) ${subnet}.${ip} ${f}" >> peers
    ip=$(expr ${ip} + 1)
done
