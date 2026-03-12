# commands.md

## Global
Commandes utiles pour tout le projet.

### Installation GNS3 (Debian)
```bash
# Dépendances (sans dynamips/software-properties-common sur Debian 13+)
sudo apt update
sudo apt install -y python3 python3-pip pipx python3-pyqt6 python3-pyqt6.qtwebsockets python3-pyqt6.qtsvg qemu-system-x86 qemu-utils libvirt-clients libvirt-daemon-system virtinst ca-certificates curl gnupg2

# Activer pipx dans le PATH
pipx ensurepath
# Puis rouvrir le terminal ou: source ~/.zshrc

# GNS3 via pipx
pipx install gns3-server
pipx install gns3-gui
pipx inject gns3-gui gns3-server PyQt6

# Lancer GNS3 (en terminal)
gns3

# Ajouter GNS3 au menu des applications (lancement graphique sans terminal)
# Fichier créé : ~/.local/share/applications/gns3.desktop
# Après création, GNS3 apparaît dans le menu (recherche « GNS3 »).
```

### PATH ~/.local/bin (si gns3 introuvable)
```bash
# Ajout dans .zshrc / .bashrc
export PATH="$PATH:$HOME/.local/bin"
```

### Dynamips (GNS3 – émulateur Cisco IOS, optionnel)
Non disponible en paquet sur Debian : compiler depuis les sources. Nécessaire seulement si un template GNS3 utilise Dynamips (ex. vieux appliances Cisco). Pour la P2 BADASS (VXLAN Linux/Docker), Dynamips n’est en général pas requis.
```bash
sudo apt install -y build-essential cmake libelf-dev libpcap-dev
git clone https://github.com/GNS3/dynamips.git && cd dynamips
mkdir build && cd build
cmake .. && make && sudo make install
cd ../.. && rm -rf dynamips
# Binaire installé dans /usr/local/bin/dynamips
# Si GNS3 ne le trouve pas : Edit > Preferences > Dynamips > Executable path → /usr/local/bin/dynamips
```

### Busybox (hosts minimalistes, GNS3)
```bash
sudo apt install busybox-static
# Pour que GNS3 le trouve (serveur avec PATH minimal) : symlink dans un chemin déjà dans le PATH
ln -sf /usr/bin/busybox ~/.local/bin/busybox
```

### Wireshark (captures, GNS3)
```bash
sudo apt install wireshark
sudo usermod -aG wireshark $USER
# Puis se déconnecter / reconnecter pour que le groupe soit pris en compte

# Si capture sans root ne marche pas : droits dumpcap (remplacer dagudelo par $USER)
sudo chgrp dagudelo /usr/bin/dumpcap
sudo chmod 754 /usr/bin/dumpcap
sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
```

### uBridge (GNS3 – ponts réseau, requis)
uBridge n’est pas dans les dépôts Debian : compiler depuis les sources.
```bash
sudo apt install -y build-essential libpcap-dev
git clone https://github.com/GNS3/ubridge.git && cd ubridge
make && sudo make install
sudo setcap cap_net_admin,cap_net_raw=ep /usr/local/bin/ubridge
cd .. && rm -rf ubridge
```
Puis se déconnecter / reconnecter (ou redémarrer la session) pour que GNS3 trouve ubridge.

### Docker (image FRR pour GNS3)
```bash
docker pull alpine
docker pull frrouting/frr

# Lancer un conteneur FRR en arrière-plan
docker run -d frrouting/frr

# Entrer dans le conteneur (remplacer boring_euler par le nom ou l’ID du conteneur)
docker exec -it boring_euler sh

# Arrêter et supprimer le conteneur
docker stop boring_euler
docker rm boring_euler

# Sauvegarder un conteneur GNS3 en image locale (remplacer le nom par celui affiché par docker ps)
docker commit GNS3.gns3-1.b89cbb2c-55b8-4415-829b-84dca6454015 gns3
docker images
```

### Console GNS3 : « AUX console port not allocated »
Le nœud utilise le type de console **AUX**, qui n’est pas alloué. Pour les conteneurs Docker (FRR, Alpine, etc.), utiliser **Telnet**.
- Clic droit sur le nœud (ex. gns3-1) → **Configure** (ou **Edit**)
- Onglet **Console** (ou **General**) : **Console type** → passer de *AUX* à **Telnet**
- Valider, puis rouvrir la console du nœud

## P1
Commandes de build, lancement, vérification des images host/router, services FRR, etc.

### Build des images P1 (noms avec dagudelo)
À lancer depuis la racine du dépôt (`BADASS/`).
```bash
docker build -t host-p1-dagudelo-1    P1/images/host_1
docker build -t host-p1-dagudelo-2    P1/images/host_2
docker build -t router-p1-dagudelo-1  P1/images/router_1
docker build -t router-p1-dagudelo-2  P1/images/router_2
```

### Pings P1 – à réaliser et qui doivent marcher
| Depuis       | Pings à faire | Doivent marcher |
|-------------|---------------|-----------------|
| **host_1**  | `ping 30.1.1.2` (router_1) | ✓ |
|             | `ping 30.1.2.2` (router_2) | ✓ |
|             | `ping 30.1.2.1` (host_2)  | ✓ |
| **host_2**  | `ping 30.1.2.2` (router_2) | ✓ |
|             | `ping 30.1.1.2` (router_1) | ✓ |
|             | `ping 30.1.1.1` (host_1)  | ✓ |
| **router_1** (vtysh: `do ping …`) | `ping 30.1.1.1` (host_1) | ✓ |
|             | `ping 10.1.1.2` (router_2) | ✓ |
|             | `ping 1.1.1.2` (router_2 lo) | ✓ |
|             | `ping 30.1.2.2` (router_2 eth1) | ✓ |
|             | `ping 30.1.2.1` (host_2)   | ✓ |
| **router_2** (vtysh: `do ping …`) | `ping 30.1.2.1` (host_2) | ✓ |
|             | `ping 10.1.1.1` (router_1) | ✓ |
|             | `ping 1.1.1.1` (router_1 lo) | ✓ |
|             | `ping 30.1.1.2` (router_1 eth1) | ✓ |
|             | `ping 30.1.1.1` (host_1)   | ✓ |

Rappel des IP : host_1 = 30.1.1.1, router_1 eth1 = 30.1.1.2 (gw) ; router_1 eth0 = 10.1.1.1, router_2 eth0 = 10.1.1.2 ; host_2 = 30.1.2.1, router_2 eth1 = 30.1.2.2 (gw).

### Vérifications P1
**Sur chaque routeur (vtysh) :**
```text
show ip ospf neighbor
show ip ospf interface
show ip route
show isis neighbor
show isis interface
```
**Depuis host_1 :** `ping 30.1.1.2` (gw), `ping 30.1.2.2`, `ping 30.1.2.1`.  
**Depuis host_2 :** `ping 30.1.2.2` (gw), `ping 30.1.1.2`, `ping 30.1.1.1`.  
**Depuis un routeur (vtysh : `do ping …`)** : ping des loopbacks (1.1.1.1, 1.1.1.2) et des IP host/eth1.

### FRR (Docker) : pas de vtysh.conf.sample
L’image `frrouting/frr` ne contient pas `/etc/frr/vtysh.conf.sample`. Créer `vtysh.conf` à la main si besoin (config intégrée) :
```bash
# Dans le conteneur ou le script d’init du nœud
echo 'service integrated-vtysh-config' > /etc/frr/vtysh.conf
chown frr:frr /etc/frr/vtysh.conf
chmod 640 /etc/frr/vtysh.conf
```
Sans ce fichier, vtysh fonctionne quand même ; le fichier sert surtout pour la config unifiée.

### badass-router-1 (vtysh – OSPF + IS-IS)
```text
vtysh
show interface
conf t
int lo
ip addr 1.1.1.1/32
int eth0
ip addr 10.1.1.1/30
router ospf
network 0.0.0.0/0 area 0
exit
router isis 1
net 49.0000.0000.0001.00
int lo
ip router isis 1
exit
int eth0
ip router isis 1
exit
do show isis interface
do show isis neighbor
do show ip route
```

### badass-router-2 (vtysh – OSPF + IS-IS + vérifs)
```text
vtysh
conf t
int lo
ip addr 1.1.1.2/32
int eth0
ip addr 10.1.1.2/30
router ospf
network 0.0.0.0/0 area 0
exit
do show ip ospf interface
do show ip ospf neighbor
do show ip route
do ping 1.1.1.1
router isis 1
net 49.0000.0000.0002.00
int lo
ip router isis 1
exit
int eth0
ip router isis 1
exit
do show isis interface
do show isis neighbor
do show ip route
```

## P2
Commandes VXLAN statique, multicast, bridge, FDB, captures réseau, etc.

### Build des images P2 (noms avec dagudelo)
À lancer depuis la racine du dépôt (`BADASS/`).

**Unicast (VXLAN point à point) :**
```bash
docker build -t host-p2-dagudelo-1     P2/images/host_1
docker build -t host-p2-dagudelo-2     P2/images/host_2
docker build -t router-p2-dagudelo-1   P2/images/router_1_unicast
docker build -t router-p2-dagudelo-2   P2/images/router_2_unicast
docker build -t router-p2-dagudelo-1-u   P2/images/router_1_unicast
docker build -t router-p2-dagudelo-2-u   P2/images/router_2_unicast
docker build -t router-p2-dagudelo-1-m   P2/images/router_1_multicast
docker build -t router-p2-dagudelo-2-m   P2/images/router_2_multicast
```


Topologie : **Ethernet-switch-dagudelo-1** (e0 ↔ router-dagudelo-1 eth0, e1 ↔ router-dagudelo-2 eth0) ; chaque routeur eth1 vers un host. Underlay 10.1.1.0/24 (eth0), overlay 30.1.1.0/24 (bridge br0 + VXLAN VNI 10).

### router-dagudelo-1 (VXLAN statique, VTEP)
```bash
ip addr add 10.1.1.1/24 dev eth0
ip link set eth0 up
ip link set eth1 up

ip link add br0 type bridge
ip link set br0 up

ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2 local 10.1.1.1 dstport 4789
ip link set vxlan10 up
ip link set eth1 master br0
ip link set vxlan10 master br0

ip addr show dev eth0
ip link show dev eth1
ip link show dev br0
ip link show dev vxlan10
bridge link
bridge fdb show
```

### router-dagudelo-2 (VXLAN statique, VTEP)
```bash
ip addr add 10.1.1.2/24 dev eth0
ip link set eth0 up
ip link set eth1 up

ip link add br0 type bridge
ip link set br0 up

ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789
ip link set vxlan10 up
ip link set eth1 master br0
ip link set vxlan10 master br0

ip addr show dev eth0
ip link show dev eth1
ip link show dev br0
ip link show dev vxlan10
bridge link
bridge fdb show
```

### host-dagudelo-1
```bash
ip addr add 30.1.1.1/24 dev eth1
```

### host-dagudelo-2
```bash
ip addr add 30.1.1.2/24 dev eth1
```

### Vérifications P2
**Sur chaque VTEP (router-dagudelo-1/2) :**
```bash
ip addr show
ip link show
bridge link
bridge fdb show
bridge fdb show dev vxlan10
```
**Depuis host_1 :** `ping 30.1.1.2` (host_2).  
**Depuis host_2 :** `ping 30.1.1.1` (host_1).  
**Optionnel (capture VXLAN)** : `tcpdump -i eth0 -n udp port 4789` sur un VTEP.

## P3
Commandes OSPF (underlay), BGP EVPN, RR, vérification overlay/underlay.

### Build des images P3 (noms avec dagudelo)
À lancer depuis la racine du dépôt (`BADASS/`).
```bash
docker build -t rr-p3-dagudelo           P3/images/rr
docker build -t router-p3-dagudelo-1     P3/images/router_1
docker build -t router-p3-dagudelo-2     P3/images/router_2
docker build -t router-p3-dagudelo-3     P3/images/router_3
docker build -t host-p3-dagudelo-1       P3/images/host_1
docker build -t host-p3-dagudelo-2       P3/images/host_2
docker build -t host-p3-dagudelo-3       P3/images/host_3
```

```bash
docker build -t rr-p3-chchao           P3/config_files/rr
docker build -t router-p3-chchao-1     P3/config_files/router_1
docker build -t router-p3-chchao-2     P3/config_files/router_2
docker build -t router-p3-chchao-3     P3/config_files/router_3
docker build -t host-p3-chchao-1       P3/config_files/host_1
docker build -t host-p3-chchao-2       P3/config_files/host_2
docker build -t host-p3-chchao-3       P3/config_files/host_3
```
```bash
docker system prune -a

docker save router-p3-chchao-1  > _chchao-1_host
docker save router-p3-chchao-2  > _chchao-2_host
docker save router-p3-chchao-3  > _chchao-3_host

docker load < _chchao-1_host
docker load < _chchao-2_host
docker load < _chchao-3_host
```

### RR (dagudelo-rr) – config.sh
Interfaces underlay eth0, eth1, eth2 vers les trois VTEPs ; pas de bridge ni VXLAN.
```bash
ip link set lo up
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up
/usr/lib/frr/frrinit.sh start
```

### RR (dagudelo-rr) – frr.conf / vtysh
```text
hostname dagudelo-rr
no ipv6 forwarding
!
interface eth0
 ip address 10.1.1.1/30
!
interface eth1
 ip address 10.1.1.5/30
!
interface eth2
 ip address 10.1.1.9/30
!
interface lo
 ip address 1.1.1.1/32
!
router bgp 1
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1
 neighbor ibgp update-source lo
 bgp listen range 1.1.1.0/29 peer-group ibgp
 !
 address-family l2vpn evpn
  neighbor ibgp activate
  neighbor ibgp route-reflector-client
 exit-address-family
!
router ospf
 network 0.0.0.0/0 area 0
!
line vty
!
```

### router_1 (dagudelo_1, VTEP) – config.sh
Underlay eth0, host eth1 dans br0.
```bash
ip link set lo up
ip link set eth0 up
ip link set eth1 up
ip link add br0 type bridge
ip link set dev br0 up
ip link add name vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth1
/usr/lib/frr/frrinit.sh start
```

### router_1 (dagudelo_1) – frr.conf / vtysh
```text
hostname dagudelo_1
no ipv6 forwarding
!
interface eth0
 ip address 10.1.1.2/30
!
interface lo
 ip address 1.1.1.2/32
!
router bgp 1
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 !
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
!
router ospf
 network 0.0.0.0/0 area 0
!
```

### router_2 (dagudelo-2, VTEP) – config.sh
Underlay eth1, host eth0 dans br0.
```bash
ip link set lo up
ip link set eth0 up
ip link set eth1 up
ip link add br0 type bridge
ip link set dev br0 up
ip link add name vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth0
/usr/lib/frr/frrinit.sh start
```

### router_2 (dagudelo-2) – frr.conf / vtysh
```text
hostname dagudelo-2
no ipv6 forwarding
!
interface eth1
 ip address 10.1.1.6/30
!
interface lo
 ip address 1.1.1.3/32
!
router bgp 1
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 !
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
!
router ospf
 network 0.0.0.0/0 area 0
!
```

### router_3 (dagudelo-3, VTEP) – config.sh
Underlay eth2, host eth0 dans br0.
```bash
ip link set lo up
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up
ip link add br0 type bridge
ip link set dev br0 up
ip link add name vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth0
/usr/lib/frr/frrinit.sh start
```

### router_3 (dagudelo-3) – frr.conf / vtysh
```text
hostname dagudelo-3
no ipv6 forwarding
!
interface eth2
 ip address 10.1.1.10/30
!
interface lo
 ip address 1.1.1.4/32
!
router bgp 1
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 !
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
!
router ospf
 network 0.0.0.0/0 area 0
!
```

### host_1 / host_2 / host_3 – config.sh
Overlay 192.168.10.0/24 sur l’interface connectée au VTEP (eth1 pour host_1, eth0 pour host_2 et host_3).
```bash
# host_1 (eth1 → router_1)
ip link set eth1 up
ip addr add 192.168.10.1/24 dev eth1

# host_2 (eth0 → router_2)
ip link set eth0 up
ip addr add 192.168.10.2/24 dev eth0

# host_3 (eth0 → router_3)
ip link set eth0 up
ip addr add 192.168.10.3/24 dev eth0
```

### Vérifications P3
**Sur RR ou VTEP (vtysh) :**
```text
show ip ospf neighbor
show ip route
show ip bgp summary
show bgp l2vpn evpn
```
**Sur un VTEP (shell)** : `bridge link` ; `bridge fdb show dev vxlan10` (après connexion des hosts).  
**Depuis chaque host** : ping des autres hosts du même VNI 10 (adresses selon ton config.sh).

### Vérification globale P3 (le projet marche)
Ordre conseillé pour confirmer que tout fonctionne.

**1. Underlay (RR et chaque VTEP, vtysh)**  
- `show ip ospf neighbor` : le RR doit voir 3 voisins OSPF ; chaque VTEP en voit 1 (le RR).  
- `show ip route` : routes OSPF vers 10.1.1.0/30, 1.1.1.1/32, 1.1.1.2/32, etc.

**2. BGP EVPN (RR et chaque VTEP, vtysh)**  
- `show ip bgp summary` : le RR a 3 voisins BGP (1.1.1.2, 1.1.1.3, 1.1.1.4) ; chaque VTEP a 1 voisin (1.1.1.1).  
- `show bgp l2vpn evpn` : routes type 2 (MAC/IP) et type 3 (inclusive multicast) présentes.

**3. Overlay (sur un VTEP, shell)**  
- `bridge link` : vxlan10 et l’interface host (eth0 ou eth1) dans br0.  
- `bridge fdb show dev vxlan10` : entrées MAC après trafic entre hosts.

**4. Pings – underlay (depuis RR ou un VTEP, vtysh)**  
- `do ping 1.1.1.2` (router_1), `do ping 1.1.1.3` (router_2), `do ping 1.1.1.4` (router_3). Tous doivent répondre.

**5. Pings – overlay (entre hosts)**  
Une fois les IP configurées sur les hosts (même sous-réseau dans le VNI 10, ex. 192.168.10.1/24, 192.168.10.2/24, 192.168.10.3/24 sur l’interface connectée au VTEP) :

| Depuis   | Pings à faire        | Doivent marcher |
|----------|----------------------|-----------------|
| **host_1** | `ping 192.168.10.2` (host_2) | ✓ |
|           | `ping 192.168.10.3` (host_3) | ✓ |
| **host_2** | `ping 192.168.10.1` (host_1) | ✓ |
|           | `ping 192.168.10.3` (host_3) | ✓ |
| **host_3** | `ping 192.168.10.1` (host_1) | ✓ |
|           | `ping 192.168.10.2` (host_2) | ✓ |

Si ces étapes sont OK, le projet P3 fonctionne en global (underlay OSPF, BGP EVPN, overlay VXLAN 10, pings entre hosts).

## Debug / Verification
```bash
# Vérifier interfaces et adresses
ip addr show
ip link show

# Table de routage
ip route
# ou en vtysh : show ip route

# Bridge et FDB (P2/P3)
bridge link
bridge fdb show
bridge fdb show dev vxlan10

# Capture (remplacer eth0 par l’interface voulue)
tcpdump -i eth0 -n
tcpdump -i eth0 -n udp port 4789
tcpdump -i br0 -n

# Voisins OSPF / BGP (vtysh)
show ip ospf neighbor
show ip bgp summary
show bgp l2vpn evpn
```

## Export GNS3 (sujet)
Pour chaque partie (P1, P2, P3) : **File → Export portable project** (ZIP avec images de base). Déposer le fichier exporté dans le dossier correspondant du dépôt pour qu’il soit visible lors de l’évaluation.