#import "settings.typ": *

// For checking layout
// #import "@preview/scaffolder:0.2.1": scaffolding
// #set page(background: scaffolding())

#show: report

///////// Title, Preamble
#set page(numbering: "a")
#showFooter("none")
#include "title.typ"

// #include "certificate.typ"
// #set page(margin: (left: 1.3in, right: 1.2in, top: 1.2in, bottom: 1.2in))
#include "acknowledgment.typ"
#include "abstract.typ"

#set page(numbering: "i")
#showFooter("number")
#counter(page).update(1)
#include "tocloft.typ"

////// Content

#counter(page).update(1)
#set page(
  numbering: "1",
  margin: (left: 1.2in, right: 1in, y: 1.5in),
)


#showFooter("doe-number")
#include "introduction.typ"
#include "method.typ"
#include "results.typ"
#include "conclusion.typ"
#pagebreak()
#set par(leading: .5em, spacing: .9em)
#bibliography("bib.yaml", title: [References])
#set page(
  margin: (left: 1in, right: 0.8in, y: 1in),
)
#showFooter("number")
#include "appendix.typ"