#import "settings.typ": addToPDFBookmark, fontsizes
#place(center+top, float: true, scope: "column")[
  #addToPDFBookmark("Abstract")
  #text(size: fontsizes.heading1)[*Abstract*]
]
  This project presents the design and implementation of a distributed, low-cost communication system specifically for person localization in a forest using a mesh network. The system is built on STM32 and uses nRF24L01+ transceivers to achieve 2.4GHz wireless links with across the network.
  Unlike traditional star topologies, the nodes operate within a software-defined mesh, utilizing a controlled flooding algorithm to ensure near fault tolerant message delivery across nodes, even in challenging RF environments. A primary feature of the implementation is the custom path-recording within packets transmitted by node; each data packet carries a telemetry header that logs the unique identifiers of every intermediary relay node. This mechanism allows for tracking of person's location within the network's topology and facilitates fast rescue operation.