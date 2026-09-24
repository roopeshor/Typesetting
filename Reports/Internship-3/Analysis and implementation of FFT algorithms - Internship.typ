#import "settings.typ": *
// #import "@preview/scaffolder:0.2.1": scaffolding
// #set page(background: scaffolding())

#show: report

///////// Title, Preamble
#set page(numbering: "a")
#showFooter("none")
#showHeader(false)
#set page(margin: 1.5in)
#include "title.typ"
#set page(margin: (
  left: 1.2in + .5cm,
  right: 1.2in,
  top: 1.2in,
  bottom: 1.2in
))

#include "certificate.typ"
#include "acknowledgment.typ"

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
#include "about.typ"
#include "introduction.typ"

#include "methods.typ"

#include "summary.typ"
#include "conclusion.typ"
#include "scope.typ"

#pagebreak()
#showFooter("none")
#showHeader(false)
#bibliography("bib.yaml", style: "ieee", title: [References], full: true)
#set page(margin: (top: 1.2in, bottom: 1in))
#include "appendix.typ"
