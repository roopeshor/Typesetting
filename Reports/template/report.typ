#import "settings.typ": *

// For checking layout
// #import "@preview/scaffolder:0.2.1": scaffolding
// #set page(background: scaffolding())

#show: report

///////// Title, Preamble
#set page(numbering: "a")
#showFooter("none")
#include "title.typ"

#include "certificate.typ"
#set page(margin: (left: 1.3in, right: 1.2in, top: 1.2in, bottom: 1.2in))
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
#include "formatting.typ"

#pagebreak()
#showFooter("none")
#showHeader(false)

// remove full:true to only show references used in the document
#bibliography(
	"bib.yaml",
	style: "ieee",
	title: [References],
	full: true
)

#include "appendix.typ"
