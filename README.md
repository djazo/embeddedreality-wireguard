# embeddedreality-wireguard

Alpine 3.14 image with wireguard tools and wireguard-go userspace

## Usage:

Surely you just rushed and did docker run before even thinking about reading this, so it gave you what ENV variables to set. Let's go through them:  
`ER_ADDRESS` VPN address of the host `ER_ADDRESS=192.168.200.1`  
`ER_PORT` UDP port to listen in, `ER_PORT=54321`  
`ER_KEYFILE` Filename with path to private key, `ER_KEYFILE=/secrets/keyfile`  
`ER_PEERS` Filename with path to peers file, `ER_PEERS=/secrets/peers`  
`ER_SUBNET` IP subnet where to add route to.  `ER_SUBNET=192.168.210.0`  

Keyfile is just file with one line, private key:
```
uCJ7dMTJmIxq0bYvx2N6YtphxIH9OQUJhZtm6wIopUc=
```
Here is example `peers` file: 
```
Dm1ivZo3EZId8168+6rNQgxUTa0gpFq4j0Ewe20QuBQ= 192.168.200.2 peter
a9ybwrTDPMHVbOm/y1oBQH3mCrm3kMbUVdkwM6tXbkY= 192.168.200.3 lois
ivzTxJB3FTULAcarq4lTYRjtCn7lMoyjyu7DVNajwl8= 192.168.200.4 chris
5QsfyDu4NwI0zNzEZ9uYTzdeev0EYrc1wpc1gUCNUk8= 192.168.200.5 meg
f0wZFNjxN4Dwo7+XZKOeYTdGmYWTQiAleqtdNEbfZk0= 192.168.200.6 stewie
79c7XrcOKLnuYPe4gRb80+v/xFnPrtFYgRcRFaF9fkI= 192.168.200.7 brian
```
Format is simply:
`<public key> <ip address> <hostname>` 
You can use script `keygenerator.sh` that will generate bunch of keys and peer file for you.

First create docker subnet that you want to have access from wg peers (clients), so you know what to give as `ER_SUBNET`
```
# docker network create --subnet 192.168.210.0/24 my-vpnstack
```
Then start the container:
```
# docker run -d --mount source=secrets,target=/secrets \
-p 54321:54321/udp \
-e ER_ADDRESS=192.168.200.1 \
-e ER_PORT=54321 \
-e ER_KEYFILE=/secrets/privkey \
-e ER_PEERS=/secrets/peers \
-e ER_SUBNET=192.168.210.0 \
--network my-vpnstack \
--cap-add=NET_ADMIN \
embeddedreality/wireguard:1.0.0
```

