#import "@preview/acrostiche:0.7.0": *
= Results and Limitations

== Results
Initially direct connection between transmitter and receiver was tested, which was successful. Then we moved on to 3 node and finally to 4 node communication as shown in @4-node. Here the radio modules showed very poor range, hence for transmission to occur, they had to be placed very close to each other. Here transmitter (shown on left) could transmit only up to the nearest repeater which relays it to receiver node (shown on right). Since #acr("ACK") mechanism was implemented the signal has to travels back to transmitter again through the repeater.


#figure(
  image("images/4 nodes.jpg", width: 12cm),
  caption: [Communication with 4 nodes]
)<4-node>
The output from all nodes were logged through Serial port and are displayed in the console using *_Minicom_* @minicom, as shown in @minicom-op. 


Later on we tested with all 4 nodes and formed the network which we originally intended to. During operation, on most case the packet travels through both repeaters and reaches the destination at almost the same time. However the radio library we used picks up only one of these packets and the program logs its signature. Hence when the other packet reaches the node, it simply discards it. In similar way, repeater nodes might obtain packets from other repeaters. But the nodes are programmed to detect and discard these duplicate packets, preventing the network from collapsing due to looping.
#figure(
  image("images/serial-outputs.png"),
  caption: [Serial output from Transmitter, Receiver and Repeater nodes (left to right)]
)<minicom-op>

During the testing we found there was some packet, possibly due to the way the RF module itself works. The details are mentioned in @limitations



== Latency Measure

Many serial print function calls and delays were added in the program for debugging purpose. To measure the transmission latency these were removed during the transmission and reception period and only essential logging functionality was left out. The latency here refers to the time period between transmission of SOS signal and reception of a ACK signal. The multiple SOS signals were sent in succession and the latency was logged.

In a direct communication, the latency was highly predictable with an averages value of 1304$mu$s (latency in each transmission is shown in @tab:direct-latency). Since a packet has maximum size of 32 bytes, the maximum date rate for our network scheme is approximately 24 KiB/s

#figure(
  caption: "Latency for direct communication",
  table(
    align: center+horizon,
    inset: 9pt,
    columns: 10,
    [*Latency\
    ($mu s$)*], [1301], [1306], [1312], [1304], [1304], [1304], [1305], [1304], [1304],
    [*Average*],table.cell(colspan: 9)[*1304$mu s$*]
  )
)<tab:direct-latency>

#figure(
  image("images/latency-direct.png", width: 10cm),
  caption: [Serial messages in generated in round trip transmission]
)

For a 3 node communication however, we saw significant increase in latency of almost 30 fold increase. Our speculation for this steep increase is signal attenuation (hence packet loss) as well as #acrf("ESB") feature of nRF24L01+ chip. Which automatically transmits same packet multiple times in a network

Based on this, the maximum data rate of the communication possible is less than 1KiB/s
#figure(
 caption: "Latency for 3 node communication",
  table(
  columns: 5,
  align: center+horizon,
  inset: 12pt,
  [*Latency($mu s$)*], [32198], [32210], [32023], [32034],
  [*Average*],table.cell(colspan: 4)[*32116
$mu s$*]
) 
)
== limitations <limitations>
The prototype is not free of limitations, and there are lot of areas that can be improved on. They are listed below.

=== RF module limitations
The physical RF layer of this prototype is powered by the standard nRF24L01+ transceiver (without the external #acr("PA+LNA")). While these choice keeps us to demonstrate the proof-of-concept of algorithm, it introduces specific limitations:

+ *Range Constraints*: Without a #acr("PA+LNA"), the transmission range of the standard nRF24L01+ is strictly limited (typically 10 to 30 meters depending on obstacles). In a real forest deployment, RF absorption by trees would further reduce this range, necessitating a higher density of relay nodes.
+ *MAC-Layer Abstraction*: The nRF24L01+ chip features a built-in hardware protocol called #acr("ESB"). ESB automatically handles hardware-level #acp("ACK") and auto-retransmissions (automatically resending a failed packet up to 3 times, or up to 15 times depending on register settings). While highly useful for simple point-to-point links, this hardware abstraction removes granular software control from the developer. It makes it difficult to implement custom algorithms at the #acr("MAC") layer, as the hardware dictates the timing of the retransmissions independent of software defined mesh logic in STM.

=== Geolocating Nodes
The task of identifying physical location of nodes is left to the maintainers or personal handling the initial setup. This will not be much of an issue if the network being built is relatively small with few number of nodes. However it can get very complicated as number of nodes increases in very vast networks. Possible solution is to develop a software that can automatically log the ID of each node and the current location of the device. This can be used during setting up of the network.

=== Security
The prototype has some security flaws which a bad actor can utilize to take down the whole network. Most importantly, the network is susceptible to overflooding due to repeated transmission of SOS signals. This could be solved by modification to existing protocol or using more advanced systems like Meshtastic.