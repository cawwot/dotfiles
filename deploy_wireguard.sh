#!/bin/bash

systemctl stop wg-quick@wg0.service || exit 1
rm -f /etc/wireguard/wg0.conf
rm -rf /etc/wireguard/keys
rm -rf /etc/wireguard/clients
rm -f /home/ia/*.qr

mkdir -p /etc/wireguard/keys || exit 1
cd /etc/wireguard/keys || exit 1
wg genkey | tee privatekey | wg pubkey > publickey
privateKey=`cat /etc/wireguard/keys/privatekey`
wg genkey | tee clientprv | wg pubkey > clientpub
clientKey=`cat /etc/wireguard/keys/clientpub`

echo '[Interface]' >> /etc/wireguard/wg0.conf
echo 'Address = 192.168.5.1/24' >> /etc/wireguard/wg0.conf
echo 'PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' >> /etc/wireguard/wg0.conf
echo 'PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE' >> /etc/wireguard/wg0.conf
echo 'ListenPort = 51820' >> /etc/wireguard/wg0.conf
echo "PrivateKey = $privateKey" >> /etc/wireguard/wg0.conf
echo 'SaveConfig = true' >> /etc/wireguard/wg0.conf
echo '' >> /etc/wireguard/wg0.conf
echo '[Peer]' >> /etc/wireguard/wg0.conf
echo "PublicKey = $clientKey" >> /etc/wireguard/wg0.conf
echo 'AllowedIPs = 192.168.5.2/32' >> /etc/wireguard/wg0.conf

chmod 600 /etc/wireguard/wg0.conf

clientKey=`cat /etc/wireguard/keys/clientprv`
publicKey=`cat /etc/wireguard/keys/publickey`
extIp=`dig @resolver1.opendns.com ANY myip.opendns.com +short`

client_name1=`shuf -n1 /usr/share/dict/words | tr -d '[:punct:]'`
client_name2=`shuf -n1 /usr/share/dict/words | tr -d '[:punct:]'`
client_name="${client_name1}_${client_name2}"

mkdir -p /etc/wireguard/clients
touch /etc/wireguard/clients/$client_name.conf

echo '[Interface]' >> /etc/wireguard/clients/$client_name.conf
echo "PrivateKey = $clientKey" >> /etc/wireguard/clients/$client_name.conf
echo 'Address = 192.168.5.2/32' >> /etc/wireguard/clients/$client_name.conf
echo 'DNS = 1.1.1.1' >> /etc/wireguard/clients/$client_name.conf
echo 'ListenPort = 51820' >> /etc/wireguard/clients/$client_name.conf
echo '' >> /etc/wireguard/clients/$client_name.conf
echo '[Peer]' >> /etc/wireguard/clients/$client_name.conf
echo "PublicKey = $publicKey" >> /etc/wireguard/clients/$client_name.conf
echo "Endpoint = $extIp:51820" >> /etc/wireguard/clients/$client_name.conf
echo 'AllowedIPs = 0.0.0.0/0, ::/0' >> /etc/wireguard/clients/$client_name.conf

qrencode -t ansiutf8 < /etc/wireguard/clients/$client_name.conf > /home/ia/$client_name.qr

#wg-quick up wg0 || exit 1
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service || exit 1
echo systemctl show -p SubState --value wg0.service

ufw allow 51820/udp
ufw allow ssh
ufw --force enable

exit 0
