
#import "@preview/headcount:0.1.0": *

/* showFooterState: Possible values:
 * doe-number
 * number
 * none
 */

#let showFooterState = state("showFooterState", "doe-number")
#let showHeaderState = state("showHeaderState", true)
#let showFooter(type) = showFooterState.update(type)
#let showHeader(bool) = showHeaderState.update(bool)

#let report-title = "Wind Profile Estimation for K-Band Doppler Radar Based on Mutual Convolution Cost Function Method"

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

#let fontsizes = (
  chap: 18pt,
  heading1: 18pt,
  heading2: 14pt,
  heading3: 12pt,
  headfoot: 11pt, // header and footer
  body: 12pt,
)
// font names
#let fontfams = (
  body: "Times New Roman PS",
  code: "DejaVu Sans Mono",
)

#let addToPDFBookmark(entry, outlined: false) = {
  show heading: none
  heading(numbering: none, bookmarked: true, outlined: outlined)[#entry]
}

#let numbered_eq(content) = math.equation(
  block: true,
  numbering: dependent-numbering("(1.1)"),
  content,
)

#let show_eqnum(eq) = context {
  let el = query(eq).first()

  numbering(dependent-numbering("(1.1)"), ..counter(math.equation).at(el.location()))
}


// 1. Keep the global tracking state
#let in-figure-outline = state("in-figure-outline", false)

// 3. Keep your flexible caption function linked to the safe state
#let flex-caption(long, short) = context {
  if in-figure-outline.get() { short } else { long }
}

#let report(body) = {
  set par(justify: true, first-line-indent: 1em, leading: .8em)
  set text(font: fontfams.body, size: fontsizes.body)
  set heading(numbering: "1.")
  set list(indent: 1em)
  set enum(indent: 1em)
  set figure(
    gap: 15pt,
    numbering: dependent-numbering("1.1"),
  )

  set page(
    footer: context {
      if showFooterState.get() == "doe-number" {
        text(size: fontsizes.headfoot)[
          _Division of Electronics Engg, SOE, CUSAT_
          #h(1fr)
          #counter(page).display()
        ]
      } else if showFooterState.get() == "number" {
        [
          #align(center)[#counter(page).display()]
        ]
      }
    },
    header: context {
      if showHeaderState.get() {
        let current-page = here().page()
        let has-heading = query(heading.where(level: 1)).any(it => it.location().page() == current-page)
        if counter(heading).get().first() > 0 and not has-heading [
          // Display header from 1st numbered heading
          #text(size: 11pt, style: "italic")[Seminar Report]
        ]
      }
    },
  )

  // Show title along with section numer
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading {
      link(el.location(), [#emph[#it: #el.body]])
    } else {
      it
    }
  }

  show heading.where(level: 1): it => {
    set align(center + top)
    if it.numbering == none [
      #text(size: fontsizes.heading1, weight: "bold")[#upper[#it.body]]
    ] else [
      #pagebreak(weak: true)
      #block[
        #text(size: fontsizes.chap, weight: "bold")[
          Chapter #counter(heading).get().first()
        ]\
        #text(size: fontsizes.heading1, weight: "bold")[#it.body]
        #counter(figure.where(kind: image)).update(0)
        #counter(figure.where(kind: table)).update(0)
        // spacing after heading
        #v(.5cm)
      ]]
  }

  show heading.where(level: 2): it => {
    if it.numbering == none [
      #text(size: fontsizes.heading2, weight: "bold")[#it.body]
    ] else [
      #block[
        #v(10pt)
        #text(size: fontsizes.heading2, weight: "bold")[
          #counter(heading).display().trim(".") #it.body
        ]
        // spacing after heading
        #v(7pt)
      ]
    ]
  }

  show heading.where(level: 3): it => {
    block[
      #v(3pt)
      #text(size: fontsizes.heading3, weight: "bold")[
        #counter(heading).display().trim(".") #it.body
      ]
      #v(2pt)
    ]
  }

  // Set spacing and font for heading outline
  show outline.entry.where(level: 1): it => {
    if it.element.func() == heading {
      v(5pt)
      strong(it)
    } else {
      v(3pt)
      it
    }
  }

  show outline.entry: it => {
    // things that shouldnt be numbered
    let no-nums = query(label("unnumbered"))
    if it.element in no-nums {
      return strong[
        #it.body()
        // dots
        #box(width: 1fr, repeat(gap: 0.15em)[.]) #it.page()
      ]
    }
    it
  }

  // set spacing around figure
  show figure: set block(spacing: 20pt)

  // put caption on top
  show figure: set figure.caption(position: top)

  // italicize figure caption
  show figure.caption: it => { emph[#it] }

  // code font
  show raw: set text(font: fontfams.code)

  show outline: it => {
    if it.target == figure.where(kind: image) {
      in-figure-outline.update(true)
      it
      in-figure-outline.update(false)
    } else {
      it
    }
  }
  // contents
  body
}
