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
// #let author = "SIDHARTH T P"
// #let regNo = "20323093"
#let author = "Roopesh O R"
#let regNo = "20323085"

// #let author = "SUMAYYA PUNNOTH"
// #let regNo = "20323100"

// #let author = "WASEEM ANWAR"
// #let regNo = "20323108"

#let fontsizes = (
  chap: 17pt,
  heading1: 15pt,
  heading2: 13pt,
  heading3: 12pt,
  headfoot: 11pt,
)


#let addToPDFBookmark(entry, outlined: false) = {
  show heading: none
  heading(numbering: none, bookmarked: true, outlined: outlined)[#entry]
}

#let project(body) = {
  set par(justify: true, first-line-indent: 1em, leading: .75em)
  set text(font: "Nimbus Roman", size: 11pt)
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
          #text(size: 11pt)[_Distributed Communication Network_]
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
      #text(size: fontsizes.heading1, weight: "bold")[#it.body]
      #it.has("unnumbered")
    ] else [
      #pagebreak(weak: true)
      #block[
        #text(size: fontsizes.chap, weight: "bold")[
          Chapter #counter(heading).get().first():
        ]\
        #text(size: fontsizes.heading1, weight: "bold")[#it.body]
        #counter(figure.where(kind: image)).update(0)
        #counter(figure.where(kind: table)).update(0)
        #v(1cm)
      ]]
  }

  show heading.where(level: 2): it => {
    block[
      #v(10pt)
      #text(size: fontsizes.heading2, weight: "bold")[
        #counter(heading).display().trim(".") #it.body
      ]
      #v(7pt)
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

  // Set spacing for heading outline
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

  show figure: set block(spacing: 25pt)
  show figure.caption: it => { emph[#it] }
  show raw: set text(font: "DejaVu Sans Mono")
  // contents
  body
}
