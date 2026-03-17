# BADASS

Network infrastructure project using GNS3 and Docker. Three parts (P1, P2, P3): basic routing, then L2 overlay with VXLAN, then BGP-EVPN with a route reflector.

---

## Project overview

- **P1** — Two routers and two hosts. Routers run FRR (OSPF, IS-IS). You build Docker images for hosts and routers, import them into GNS3, wire the topology, and check connectivity (pings and routing).
- **P2** — Two VTEPs and two hosts over an Ethernet switch. VXLAN VNI 10: first static unicast tunnels, then multicast. Bridge, VXLAN, and optional packet capture to verify overlay traffic.
- **P3** — One route reflector (RR), three VTEPs, three hosts. Underlay via OSPF; overlay via BGP EVPN. RR reflects EVPN routes; VTEPs extend the same L2 segment (VNI 10). You check underlay, BGP EVPN, and host-to-host pings.

All configuration and scripts live in **P1**, **P2**, and **P3** at the repo root.

---

## How we do it: config in the image, no typing during evaluation

Configuration is **baked into the Docker images** via config files and scripts:

- Each image is built from a folder that contains a **Dockerfile**, and usually a **config.sh** (and for FRR nodes, **frr.conf** or equivalent). The Dockerfile **COPY**s these into the image and sets the **ENTRYPOINT** (or **CMD**) so that when the container starts, it runs the config script (interfaces, addresses, bridge, VXLAN, FRR startup, etc.).
- So when you **start the nodes in GNS3**, they apply the full configuration automatically. You **do not** need to type configuration commands during the evaluation — only start the nodes and run the **verification** commands (pings, `show ip ospf neighbor`, `show bgp l2vpn evpn`, etc.) to demonstrate that everything works.

Build all images **before** the evaluation from the repo root, using the paths in `commands.md` (e.g. `docker build -t router-p3-chchao-1 P3/config_files/router_1`). Use your own tag prefix. Then in GNS3 you only need to assign the correct image to each node and start them.

---

## Topology: export/import or build during evaluation

Two valid approaches:

1. **Export portable project** — Build your topology once in GNS3 (nodes, links, which image goes where). Then **File → Export portable project** and put the ZIP in the right folder (P1, P2, or P3). During evaluation, the evaluator (or you) **imports** that project: topology and node types are already there, you start the nodes and verify.
2. **Build topology during evaluation** — Some people prefer to create the topology live (add nodes, connect links, assign images). That’s fine too. As long as the topology matches the subject and the images are the ones you built from the repo, evaluation can proceed either way.

Choose what you are comfortable with; the subject only requires that the project can be verified on the evaluation machine (clone repo, run GNS3, show that it works).

---

## Steps (summary)

1. **Clone the repo** on the machine where GNS3 and Docker run.
2. **Prerequisites** — GNS3, Docker, Busybox, uBridge (and optionally Wireshark). See `commands.md` for install notes.
3. **Folders** — **P1**, **P2**, **P3** at repo root. Each contains the files used to build that part’s images (Dockerfiles, config.sh, frr.conf, etc.).
4. **Build images** — From repo root, run the `docker build` commands in `commands.md` for each part. All configuration is inside the images; no manual config at runtime.
5. **GNS3** — Import the built Docker images as appliances. Either import an exported portable project (P1/P2/P3) or create the topology by hand. Assign the correct image to each node. For Docker nodes, set console type to **Telnet** if AUX is not allocated.
6. **Run and verify** — Start the nodes; config runs automatically. Then run the verification commands from `commands.md` (pings, OSPF/BGP/bridge checks) to show that the project works.
7. **Export (if you use a pre-built project)** — For each part, **File → Export portable project** and place the ZIP in the corresponding P1/P2/P3 folder in the repo.

Detailed commands (build, vtysh, ping tables, bridge/BGP checks) are in **`commands.md`**.
