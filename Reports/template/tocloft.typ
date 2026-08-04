#import "settings.typ": addToPDFBookmark, fontsizes
#import "@preview/acrostiche:0.7.0": *
// Table Of Contents, List Of Figures and Tables

// set listing heading style
#show heading.where(level: 1): it => {
  set align(center + top)
  block[
    #text(size: 21pt, weight: "bold")[#it.body]
    #v(.5cm)
  ]
}

#addToPDFBookmark("Contents", outlined: false)
#outline(
  title: text(size: fontsizes.heading1)[Contents],
  target: heading,
)

#pagebreak()

#addToPDFBookmark("List of Figures", outlined: true)
#outline(
  title: text(size: fontsizes.heading2)[List of Figures],
  target: figure.where(kind: image),
)


#pagebreak()

#addToPDFBookmark("List of Tables", outlined: true)
#outline(
  title: text(size: fontsizes.heading2)[List of Tables],
  target: figure.where(kind: table),
)

#pagebreak()

#addToPDFBookmark("List of Abbreviations", outlined: true)
#init-acronyms((
  "DSP": "Digital Signal Processing",
  "FT": "Fourier Transform",
  "FFT": "Fast Fourier Transform",
  "DIT": "Decimation in Time",
  "DIF": "Decimation in Frequency",
  "DFT": "Discrete Fourier Transform",
  "WNS": "Worst Negative Slack",
  "CRT": "Chinese Remainder Theorem",
  "ASIC": "Application Specific Integrated Circuit",
))

#print-index(
  title: text(size: fontsizes.heading2)[List of Abbreviations],
  row-gutter: 10pt,
  sorted: "up",
	column-ratio: .2
)

#pagebreak()

#align(center)[
  #addToPDFBookmark("List of Symbols", outlined: true)
  #text(size: fontsizes.heading2)[*List of Symbols*]
]
#set par(leading: 1.5em)
#v(13pt)
- $integral$ - integral
- $sum$ - sum
- $partial d \/ partial x$ - differential
- $bb(C), bb(N)$ - complex, natural numbers
- $cal(H)$ - Hilbert
- $nabla$ - gradient
