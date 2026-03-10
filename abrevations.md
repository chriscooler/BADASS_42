| Abbreviation | Full term | Explanation |
|---|---|---|
| BGP | Border Gateway Protocol | Protocole de routage entre AS ; en P3 utilisé pour EVPN (plan de contrôle). |
| MP-BGP | Multiprotocol BGP | Extension BGP (RFC 4760) pour transporter des NLRI (IPv4, IPv6, EVPN, etc.). |
| OSPF | Open Shortest Path First | Protocole de routage interne (link-state) ; P1 et underlay P3. |
| IS-IS | Intermediate System to Intermediate System | Protocole de routage interne (link-state) ; exigé par le sujet BADASS en P1. |
| EVPN | Ethernet VPN | Famille BGP (RFC 7432) pour publier MAC et préfixes ; P3. |
| VXLAN | Virtual eXtensible LAN | Overlay L2 over L3 (RFC 7348) ; P2 et P3, VNI 10. |
| VNI | VXLAN Network Identifier | Identifiant de segment logique (sujet : 10). |
| VTEP | VXLAN Tunnel Endpoint | Extrémité du tunnel VXLAN (encapsulation/décapsulation). |
| RR | Route Reflector | Routeur BGP qui relaie les routes entre clients ; P3. |
| NLRI | Network Layer Reachability Information | Information de réachabilité transportée par BGP (préfixes, EVPN routes). |
| L2 / L3 | Layer 2 / Layer 3 | L2 = Ethernet, MAC ; L3 = IP, routage. VXLAN = overlay L2 over L3. |
| LSA | Link State Advertisement | Unité d’information OSPF (liens, réseaux) échangée entre routeurs. |
| eth0, eth1 | Ethernet interface 0, 1 | P1 : eth0 = inter-routeurs, eth1 = routeur–host. P2/P3 : eth0 = underlay, eth1 = host. |
| lo | Loopback | Interface logicielle ; router ID OSPF/IS-IS/BGP (ex. 1.1.1.1). |
| FDB | Forwarding Database | Table MAC → port sur un bridge ; `bridge fdb show`. |
| VTY | Virtual Teletype | Terminal virtuel ; vtysh = shell FRR unifié. |
| AS | Autonomous System | Système autonome (BGP) ; P3 entre VTEPs (souvent AS 1). |