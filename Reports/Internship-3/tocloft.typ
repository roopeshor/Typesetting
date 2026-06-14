#import "settings.typ": addToPDFBookmark, fontsizes
#import "@preview/acrostiche:0.7.0": *
// Table Of Contents, List Of Figures and Tables

#init-acronyms((
  "DSP": "Digital Signal Processing",
  "FT": "Fourier Transform",
  "FFT": "Fast Fourier Transform",
	"DIT": "Decimation in Time",
	"DIF": "Decimation in Frequency",
	"DFT": "Discrete Fourier Transform",
	"WNS": "Worst Negative Slack"
))

// set listing heading style
#show heading.where(level: 1): it => {
  set align(center + top)
  block[
    #text(size: 21pt, weight: "bold")[#it.body]
    #v(.5cm)
  ]
}

// #addToPDFBookmark("Table of contents", outlined: false)
// #outline(
//   title: text(size: fontsizes.heading1)[Table of contents],
//   target: heading,
// )

// #pagebreak()

// #addToPDFBookmark("List of Figures", outlined: true)
// #outline(
//   title: text(size: fontsizes.heading1)[List of Figures],
//   target: figure.where(kind: image),
// )


// #pagebreak()

// #addToPDFBookmark("List of Tables", outlined: true)
// #outline(
//   title: text(size: fontsizes.heading1)[List of Tables],
//   target: figure.where(kind: table),
// )

// #pagebreak()

// #addToPDFBookmark("List of Abbreviations", outlined: true)
// #print-index(
//   title: text(size: fontsizes.heading1)[List of Abbreviations],
//   row-gutter: 10pt,
//   sorted: "up",
// 	column-ratio: .2
// )

// #pagebreak()
