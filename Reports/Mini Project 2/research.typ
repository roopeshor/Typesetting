#import "@preview/acrostiche:0.7.0": *
= Literature Review

Historically, network systems have been studied for wide area communication @history and distributed computing. In earlier days sensor networks relied on centralized, _*star topology*_ architectures. In these networks, all edge devices communicate directly with a central gateway. While simple to implement, star topologies possess a single point of failure and are strictly limited by the physical transmission range of the central node . In complex environments -- such as industrial facilities with heavy RF attenuation, dense agricultural fields, or robotic swarm deployments -- maintaining direct line-of-sight to a central hub is often physically impossible or expensive. A _*common bus topology*_ was also considered but it suffers from the same problem -- need of central orchestrator.

#figure(
	grid(
		align: horizon,
		columns: 2,
		column-gutter: 40pt,
		image("images/star-e.svg", height: 6cm),
		image("images/bus-e.svg", height: 6cm),
		text([(a) Star Topology]),
		text([(b) Common Bus Topology]),
		v(10pt),
	),
	caption: [Star and Common Bus topologies]
)

In these scenario decentralized _*Mesh Networking*_ has emerged as a viable solution @wsn. In a mesh topology, individual nodes can act as originators of data and/or active relays (routers) for their peers. This cooperative data forwarding extends the effective range of the network far beyond the capability of single transmitter system and provides much higher fault tolerance; if one node fails, the network can  re-routes traffic through other existing paths. These network are self-organizing and does not require a central orchestrator.

#figure(
	image("images/mesh-e.svg", height: 6cm),
	caption: [Mesh network topology]
)

Despite the advantages of mesh topologies, implementing them in highly constrained environments is a significant engineering challenge. Standard mesh protocols, such as Zigbee has performance and interoperability issues for large networks. Furthermore, many commercial mesh solutions are proprietary or rely on heavy, power-hungry transceivers.

There are more complex systems like #acrpl("MANET"), and #acrpl("VANET") which are suited for very dynamic environments. We also explored _Meshtastic_ a sophisticated off-grid mesh networking LoRa protocol @meshtastic. However, the problem our project tries to tackle involves a relatively static environment where nodes remain in their place for long run. Hence routing scheme such as *Controlled Flooding* @controlled-flooding best suited for our problem domain. Controlled flooding is easier to implement while being light on resources.
