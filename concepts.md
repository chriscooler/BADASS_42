# concepts.md

## General concepts
- **Packet capture** : enregistrement du trafic (tcpdump, Wireshark) pour analyser les trames.
- **Encapsulation** : inclure un paquet dans un autre (ex. Ethernet dans UDP pour VXLAN).
- **Underlay** : réseau physique ou logique qui porte le tunnel (ex. 10.1.1.0/24 entre VTEPs en P2/P3).
- **Overlay** : réseau logique au-dessus du tunnel (ex. 30.1.1.0/24 en VXLAN).

## Linux networking concepts
- **Interface** : représentation logicielle d’un lien (eth0, eth1, lo, vxlan10).
- **Bridge** : commutateur L2 logiciel (ex. br0) ; relie des ports et peut inclure du VXLAN.
- **FDB** (Forwarding Database) : table MAC → port sur un bridge ; `bridge fdb show` pour l’afficher.
- **ARP** : résolution adresse IP → adresse MAC sur le lien local.
- **MAC learning** : le bridge apprend les MAC sources et envoie le trafic inconnu en broadcast ou via le tunnel (VXLAN).

## P1 – Topologie et rôles (finalisée)
- **host-p1-dagudelo-1** : host (Alpine + busybox) à gauche ; **eth1** 30.1.1.1/24, default via 30.1.1.2 ; connecté à router_1 via eth1.
- **router-p1-dagudelo-1** : routeur FRR ; **eth1** 30.1.1.2/24 vers host_1, **eth0** 10.1.1.1/30 vers router_2 ; lo 1.1.1.1/32 ; OSPF area 0 + IS-IS net 49.0000.0000.0001.00.
- **router-p1-dagudelo-2** : routeur FRR ; **eth0** 10.1.1.2/30 vers router_1, **eth1** 30.1.2.2/24 vers host_2 ; lo 1.1.1.2/32 ; OSPF area 0 + IS-IS net 49.0000.0000.0002.00.
- **host-p1-dagudelo-2** : host (Alpine + busybox) à droite ; **eth1** 30.1.2.1/24, default via 30.1.2.2 ; connecté à router_2 via eth1.
- **Chaîne** : host_1 —(eth1)— router_1 —(eth0)— router_2 —(eth1)— host_2. Config dans `commands.md` et images P1 (vtysh_commands, config.sh).

### Étapes P1 et pourquoi
1. **Topologie GNS3** (alpine-1, badass-router-1, badass-router-2, alpine-2, câblage eth0/eth1)  
   *Pourquoi* : définir la chaîne physique et les rôles (hosts, routeurs) avant toute config.

2. **Interfaces et adresses** (loopback 1.1.1.1/32 et 1.1.1.2/32, eth0 10.1.1.1/30 et 10.1.1.2/30)  
   *Pourquoi* : la loopback sert de router ID stable pour OSPF/IS-IS ; eth0/30 donne le lien point à point entre les deux routeurs.

3. **OSPF** (`router ospf`, `network 0.0.0.0/0 area 0`)  
   *Pourquoi* : faire échanger les routes entre R1 et R2 automatiquement (routage dynamique) sans routes statiques ; area 0 = backbone minimal.

4. **IS-IS** (`router isis 1`, `net 49.0000.0000.000x.00`, `ip router isis` sur lo et eth0)  
   *Pourquoi* : le sujet BADASS exige IS-IS ; on active le protocole sur les interfaces concernées pour que les routeurs deviennent voisins IS-IS.

5. **Vérifications** (`show ip ospf/isis interface`, `show ip ospf/isis neighbor`, `show ip route`, `ping` loopback)  
   *Pourquoi* : confirmer que les voisins OSPF/IS-IS sont vus, que les routes sont apprises et que la connectivité (ex. ping 1.1.1.1 depuis R2) fonctionne.

6. **Route par défaut sur les hosts** (`ip route add default via …`)  
   *Pourquoi* : un host ne connaît que son sous-réseau direct ; pour joindre l’autre segment (ex. host_2 depuis host_1), il doit envoyer le trafic à sa passerelle (le routeur).

### Conformité P1 au sujet BADASS (en.subject.pdf)
- **Deux images Docker** : (1) host basé Alpine + busybox ou équivalent ; (2) routeur avec logiciel de routage (zebra/quagga), **BGPD**, **OSPFD**, **moteur IS-IS**, busybox ou équivalent. ✓
- **Aucune IP par défaut dans les images** : les adresses sont appliquées au démarrage (config.sh, vtysh_commands). ✓
- **Nom des équipements** : chaque machine doit contenir le login du groupe (ex. dagudelo). ✓
- **Dossier P1** à la racine du dépôt, **fichiers de config commentés** par équipement. ✓
- **Export GNS3** : projet exporté en ZIP (File → Export portable project) **avec les images de base**, fichier visible dans le dépôt. ✓
- **Schéma du sujet** : le sujet montre 1 host et 1 routeur (« both machines working »). Pour faire fonctionner **IS-IS**, il faut au moins **deux routeurs** (voisinage). La topologie 2 routeurs + 2 hosts respecte les exigences (deux types d’images, services demandés) et permet de démontrer OSPF + IS-IS entre routeurs.

## P2 – Topologie et rôles (VXLAN statique)
- **Ethernet-switch-dagudelo-1** : switch central ; port e0 ↔ **router-dagudelo-1** eth0, port e1 ↔ **router-dagudelo-2** eth0 (underlay 10.1.1.0/24).
- **router-dagudelo-1** : VTEP ; eth0 10.1.1.1/24 vers le switch, eth1 vers **host-dagudelo-1** ; bridge br0 = eth1 + vxlan10 (VNI 10, remote 10.1.1.2, dstport 4789).
- **router-dagudelo-2** : VTEP ; eth0 10.1.1.2/24 vers le switch, eth1 vers **host-dagudelo-2** ; bridge br0 = eth1 + vxlan10 (VNI 10, remote 10.1.1.1, dstport 4789).
- **host-dagudelo-1** : eth1 30.1.1.1/24 (réseau overlay).
- **host-dagudelo-2** : eth1 30.1.1.2/24 (réseau overlay).
- **Flux** : tunnel VXLAN point à point entre les deux VTEPs sur l’underlay ; les hosts communiquent en 30.1.1.0/24 via le bridge et le VXLAN. Commandes dans `commands.md` section P2.
- **Mode multicast (P2)** : même topologie avec un groupe multicast (ex. 239.1.1.1) pour le flooding dynamique ; `ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789`.

## P3 – Topologie et rôles (BGP EVPN + RR)
- **RR (Route Reflector)** : nœud central ; loopback 1.1.1.1, interfaces underlay (ex. 10.1.1.1/30, 10.1.1.5/30, 10.1.1.9/30) vers les VTEPs ; BGP avec `route-reflector-client`, OSPF pour l’underlay. Pas de VXLAN sur le RR.
- **VTEPs (router_1, router_2, router_3)** : chaque VTEP a une loopback (router ID + source BGP), des interfaces underlay vers le RR/backbone, un bridge br0 avec eth vers le host et vxlan10 (VNI 10) ; BGP EVPN vers le RR, `advertise-all-vni`, OSPF pour l’underlay.
- **Hosts (host_1, host_2, host_3)** : Alpine ; connectés chacun à un VTEP ; pas d’IP par défaut dans l’image (config au démarrage si besoin). Le sujet indique que le VTEP découvre automatiquement les MAC (routes type 2).
- **Sujet** : VXLAN ID 10, OSPF pour simplifier l’évaluation, pas de MPLS ; routes type 3 (inclusive multicast) préconfigurées, type 2 créées automatiquement quand un host est actif.

### Conformité P3 au sujet BADASS
- BGP EVPN (RFC 7432), sans MPLS. ✓
- Principe de **route reflection** (RR), leaves = VTEPs en relations dynamiques. ✓
- **OSPF** pour l’underlay (simplification évaluation). ✓
- **VXLAN ID 10** comme en P2. ✓
- Dossier **P3**, configs commentées, export ZIP avec images, noms avec login. ✓

## GNS3 concepts
- **Node** : équipement dans la topologie (routeur, host, switch).
- **Appliance** : modèle pré-défini (image + paramètres) réutilisable.
- **Docker node** : nœud GNS3 basé sur une image Docker ; les interfaces correspondent aux liens branchés.
- **Packet capture in GNS3** : capture sur un lien entre deux nœuds pour inspecter le trafic (ex. VXLAN, OSPF).

## VXLAN concepts
- **VXLAN** (Virtual eXtensible LAN) : overlay L2 over L3 (RFC 7348) ; encapsule des trames Ethernet dans UDP.
- **VNI** (VXLAN Network Identifier) : identifiant du segment logique (ex. 10) ; le sujet impose VNI 10 en P2 et P3.
- **VTEP** (VXLAN Tunnel Endpoint) : extrémité du tunnel ; encapsule/décapsule le trafic VXLAN.
- **UDP 4789** : port de destination standard pour VXLAN.
- **Static flooding** : tunnel point à point (remote X local Y) ; pas de multicast.
- **Multicast flooding** : groupe multicast pour le broadcast inconnu (ex. 239.1.1.1).

## FRR concepts
- **`/etc/frr/daemons`** : active/désactive les démons (bgpd=yes, ospfd=yes, etc.). Fichier à ne pas confondre avec vtysh.conf.
- **`/etc/frr/vtysh.conf`** : options du shell vtysh (ex. `service integrated-vtysh-config`). Fichier séparé de daemons.
- **ATTENTION (daemons)** : pour qu’un démon activé démarre, il doit exister un fichier de config correspondant (vide ou non) dans `/etc/frr/` ; permissions conseillées u=rw,g=r,o=. ; avec vtysh, groupe `frrvty` et droits adaptés.

### Démons FRR (ce que sont bgpd, ospfd, etc.)
- **zebra** : démon central ; gère les routes et les interfaces (toujours actif).
- **staticd** : routes statiques (toujours actif avec zebra).
- **watchfrr** : surveille et redémarre les autres démons (souvent activé).
- **bgpd** : BGP (Border Gateway Protocol) — routage entre AS, utilisé en P3 pour BGP EVPN.
- **ospfd** : OSPF v2 (IPv4) — routage interne (underlay en P3).
- **ospf6d** : OSPF v3 (IPv6).
- **ripd** : RIP (Routing Information Protocol) — protocole à vecteur de distance, ancien.
- **ripngd** : RIP next generation (IPv6).
- **isisd** : IS-IS — routage interne (alternative à OSPF), demandé dans le sujet BADASS.
- **pimd** : PIM (Protocol Independent Multicast) — multicast IPv4.
- **pim6d** : PIM pour IPv6.

## EVPN concepts
- **EVPN** (Ethernet VPN) : famille BGP pour publier les MAC et les préfixes des hôtes derrière les VTEPs (RFC 7432).
- **MP-BGP** : BGP multi-protocole ; transporte des NLRI (ex. EVPN) en plus de l’IPv4.
- **Route type 2** (EVPN) : annonce MAC + IP d’un hôte ; permet l’apprentissage automatique des MAC via le contrôleur.
- **Route type 3** (EVPN) : annonce la réachabilité entre VTEPs (sous-réseaux VXLAN) ; type « inclusive multicast ».
- **Route Reflector (RR)** : routeur BGP qui relaie les routes entre clients sans full-mesh ; en P3 le RR est le contrôleur central.

## Debugging concepts
- **tcpdump** : capture de paquets en ligne de commande (filtres par interface, protocole, IP).
- **Wireshark** : analyse de captures avec interface graphique.
- **dumpcap** : outil de capture utilisé par Wireshark ; nécessite droits (groupe wireshark ou capabilities).
- **Capture eth0 vs vxlan10** : sur un VTEP, eth0 montre le trafic encapsulé (UDP 4789), vxlan10/br0 le trafic décapsulé (overlay).