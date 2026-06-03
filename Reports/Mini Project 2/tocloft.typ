#import "settings.typ": addToPDFBookmark, fontsizes
#import "@preview/acrostiche:0.7.0": *
// Table Of Contents, List Of Figures and Tables

#init-acronyms((
  "IoT": "Internet of Things",
  "M2M": "Machine-to-Machine",
  "COTS": "Commercial off-the-shelf",
  "UAV": "Unmanned Aerial Vehicle",
  "WSN": "Wireless Sensor Netwok",
  "MANET": "Mobile Adhoc Network",
  "VANET": "Vehicular Adhoc Network",
  "AODV": "Ad-hoc On-demand Distance Vector",
  "GNSS": "Global Navigation Satellite Systems",
  "ACK": "Acknowledgment",
  "IDE": "Integrated Development Environment",
  "LOS": "Line-of-Sight",
  "SRAM": "Static RAM",
  "SPI": "Serial Peripheral Interface",
  "I2C": "Inter-Integrated Circuit",
  "GPIO": "General Purpose I/O",
  "USART": "Universal Synchronous/Asynchronous Receiver Transmitter",
  "ESB": "Enhanced ShockBurst",
  "PA+LNA": "Power Amplifier and Low Noise Amplifier",
  "MAC": "Media Access Control",
  "DIP": "Dual in-line package"
))

// set listing heading style
#show heading.where(level: 1): it => {
  set align(center + top)
  block[
    #text(size: 21pt, weight: "bold")[#it.body]
    #v(.5cm)
  ]
}

#addToPDFBookmark("Table of contents")
#outline(
  title: text(size: fontsizes.heading1)[Table of contents],
  target: heading,
)

#pagebreak()

#addToPDFBookmark("List of Figures", outlined: true)
#outline(
  title: text(size: fontsizes.heading1)[List of Figures],
  target: figure.where(kind: image),
)
#v(1cm)
#pagebreak()
#addToPDFBookmark("List of Tables", outlined: true)
#outline(
  title: text(size: fontsizes.heading1)[List of Tables],
  target: figure.where(kind: table),
)
#v(1cm)
#pagebreak()

#addToPDFBookmark("List of Abbreviations", outlined: true)
#print-index(
  title: text(size: fontsizes.heading1)[List of Abbreviations],
  row-gutter: 10pt,
  sorted: "up",
	column-ratio: .2
)

#pagebreak()
