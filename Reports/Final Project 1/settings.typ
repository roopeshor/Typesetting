#let in-outline = state("in-outline", false)

#let alt-captions(long, short) = context if in-outline.get() { short } else { long }

#let settings = doc => {
  set page(numbering: "1")
  set text(font: "MLMRoman12", size: 11pt)
  set par(
    justify: true,
    leading: .85em,
  )

  set heading(
    numbering: "1.1.1",
  )
  show heading.where(level: 2): set block(below: 1em)
  show heading.where(level: 3): set block(below: 1em)
  ////// Chapter format
  show heading.where(level: 1): it => [
    #pagebreak()
    #align(center)[
      #if (it.body != [References]) {
        [Chapter #counter(heading).get().first():\ ]
      }
      #text(size: 1.2em)[#it.body]
    ]
    // also reset fig and eqn numbering
    #counter(math.equation).update(0)
    #counter(figure).update(0)
  ]

  ///// Figure and Caption format
  show figure.caption: set text(style: "italic")
  show figure: set block(below: 20pt)

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
  doc
}
