#import "@preview/acrostiche:0.7.0": *
#let in-outline = state("in-outline", false)

#let alt-captions(long, short) = context if in-outline.get() { short } else { long }
#let addToPDFBookmark(entry, outlined: false) = {
  show heading: none
  heading(numbering: none, bookmarked: true, outlined: outlined)[#entry]
}
#let fit-to-page(content) = context {
  let content-size = measure(content)
  layout(size => {
    if content-size.width > size.width {
      let ratio = (size.width / content-size.width) * 100%
      scale(x: ratio, y: ratio, reflow: true, content)
    } else {
      content
    }
  })
}

#let isChap = state("isChap", false);

#let settings = doc => {
  set text(font: "MLMRoman10", size: 11pt)
  set par(
    justify: true,
    leading: .8em,
    first-line-indent: 12pt
  )

  set heading(
    numbering: "1.1.1",
    supplement: [Chapter]
  )
  show heading: set par(first-line-indent: 0pt);
  show heading.where(level: 2): set block(below: 1em)
  show heading.where(level: 3): set block(below: 1em)
  show heading.where(level: 4): set heading(numbering: none)
  show heading: set text(font: "MLMRoman12")
  
  ////// Chapter format
  show heading.where(level: 1): it => [
    #align(center)[
      #if (isChap.get()) {
        pagebreak(weak: true)
        [Chapter #counter(heading).get().first():\ ]
        text(size: 1.2em)[#it.body] 
        v(0.5cm)
      } else {
        text(size: 1.1em)[#it.body] 
        v(0.5cm)
      }
    ]
    // also reset fig and eqn numbering
    #counter(math.equation).update(0)
    #counter(figure.where(kind: image)).update(0)
    #counter(figure.where(kind: table)).update(0)
  ]

  show heading.where(level: 2): it => [
   #let c = counter(heading);
    #counter(heading).display() #it.body \
  ]
  
  show heading.where(level: 3): it => [
   #let c = counter(heading).get();
    #counter(heading).display() #it.body \
  ]
  show heading.where(level: 4): it => [
    #v(5pt)
    #text(weight: "extrabold", size: 11.5pt)[#it.body] \
  ]

  ///// Figure and Caption format
  show figure.caption: set text(style: "italic")
  show figure: set block(below: 20pt, breakable: true)

  ///// Set Numbering scheme
  set math.equation(numbering: num => {
    let chap = counter(heading).get().first()
    numbering("(1.1)", chap, num)
  })

  set figure(numbering: num => {
    let chap = counter(heading).get().first()
    numbering("1.1", chap, num)
  })

  // do not number equation that is not labeled
  show math.equation: it => {
    if it.block and not it.has("label") and it.numbering != none [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)
    ] else {
      it
    }
  }

  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  show outline.entry.where(level: 1): it => {
    if it.element.func() == heading {
      v(5pt)
      strong(it)
    } else {
      v(3pt)
      it
    }
  }
  

  show ref: it => {
    let el = it.element;
    if el != none and el.func() == heading {
      link(el.location(), text(style: "italic")[#it: #el.body])
    } else {
      it
    }
  }

  set table(
    fill: (_, y) => if y == 0 { rgb("#dddddd") },
    align: (x, y) => if y == 0 { center } else { left },
    stroke: (_, y) => (
      x: 1pt,
      top: if y <= 1 { 1pt } else { 0pt },
      bottom: 1pt,
    ),
  )
  show table.cell.where(y: 0): set text(weight: "bold")

  

  init-acronyms((
    "ACARR": ("Advanced Centre for Atmospheric Radar Research"),
    "IRHPA": ("Intensification of Research in High Priority Areas"),
    "LIDAR": ("Light Detection and Ranging"),
    "DBS": ("Doppler Beam Swing"),
    "ST Radar": ("Stratosphere–Troposphere radar"),
    "IQ": ("In-phase and Quadrature"),
    "NCI": ("Non-Coherent Integration"),
    "MSE": ("Mean Square Error"),
  ))


  doc
}
