#import "@preview/acrostiche:0.7.0": *

= Introduction
Communication infrastructure is the most critical logistical component of any Search and Rescue operation. In deep, dense forests, traditional communication networks such as cellular grids or centralized VHF radio repeaters are either non-existent or rendered ineffective due to severe signal attenuation caused by foliage and uneven terrain. When search teams or lost individuals operate in these disconnected zones, the lack of a reliable communication lifeline drastically reduces the probability of a successful rescue.

To overcome the limitations of centralized networks, decentralized #acr("WSN") offer an alternative. By deploying a localized, ad-hoc mesh network, communication can be maintained by "hopping" signals from one node to another until they reach a central command station. This project demonstrates the design and implementation of such a system: a distributed multi-hop communication network designed specifically to relay critical state changes (such as an SOS signal) across separated nodes.

== System Architecture

The core objective of this prototype is to validate the feasibility of decentralized packet routing using low-cost hardware. The physical demonstration consists of a localized four-node network:

- One _*Transmitter*_: Simulating an edge device triggered by a user in distress.
- One _*Receiver*_: Acting as the gateway or rescue command center.
- Two _*Relay Nodes*_: Acting as repeaters. Because these nodes are battery-powered, forest guards could place these modules in different parts of forest to instantly establish a network.

The computation of each node is handled by an STM32 series microcontroller, which handles interfacing of nRF24L01 RF module. These four nodes are expected to be organized in a manner shown in @mesh-impl.

The system assumes that each node is already geolocated. The Based on the information in the packet the receiving station can determine which node was nearest to the transmitter and hence can obtain a approximate location of the transmitter.
A #acs("GNSS") module can be attached to each node to locate its position on the fly, reducing manual labor of tagging each node. However the addition of a GNSS module can increase the cost of whole system several times. Also once the nodes are placed int various locations, their position is fixed, hence GNSS module will become redundant.
#figure(
	image("images/mesh-impl.svg", height: 6cm),
 gap: 0pt,
	caption: [Intended organization of nodes]
)<mesh-impl>

== Protocol Design

A primary decision in this project was the not to use heavy, conventional mesh routing protocols like #acr("AODV") or Zigbee. While these protocols are highly efficient in static, enterprise-grade networks, they require significant effort to get started and to maintain routing tables and calculate shortest-path vectors. Since no #acs("GNSS") system is incorporated the node distance is not directly computable.

Considering the data available to each node we decided to implemented Controlled Flooding. In a flooding architecture, an intermediate node simply broadcasts any packet it receives that is not addressed to itself. To prevent the network from collapsing under infinite routing loops (known as a "broadcast storm"), the flooding is strictly controlled via software. Each node maintains a localized "seen stack" -- an array of details of recently transmitted packets. If a packet's signature exists in the stack, it is dropped; if it is new, it is forwarded. This ensures redundancy and that an SOS signal will aggressively find the fastest physical path through the forest to the receiver, without the nodes needing to map the network topology in advance.

In emergency communications, "fire-and-forget" transmission is unacceptable; the Transmitting node must know if the distress signal successfully reached the command station (Receiver). To signal the successful data delivery, the system implements an application-layer #acr("ACK") mechanism. When the final destination node successfully receives the targeted packet, it generates a distinct #acr("ACK") packet and routes it back through the mesh to the original transmitter. The transmitter node after transmitting SOS goes to listening state, and upon receiving this targeted #acr("ACK"), the node provides physical feedback (via an LED indicator) to confirm that the transmission successfully reached the command station.