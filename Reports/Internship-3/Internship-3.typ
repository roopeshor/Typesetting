#import "settings.typ": *
#show: report

///////// Title, Preamble
/// 
// #set page(numbering: "a")
// #showFooter("none")
// #include "title.typ"
// #include "certificate.typ"
// #set page(margin: (left: 1.3in, right: 1.2in, top: 1.2in, bottom: 1.2in))
// #include "acknowledgment.typ"
// #include "abstract.typ"

// #set page(numbering: "i")
// #showFooter("number")
// #counter(page).update(1)
#include "tocloft.typ"



////// Content

#counter(page).update(1)
#set page(
  numbering: "1",
  margin: (left: 1.2in, right: 1in, y: 1.5in),
)


#showFooter("doe-number")
#include "introduction.typ"
//    |-- Objective
//    |-- background work
// |-- Methods
//    |-- DIT r2_inplace
// 	 |-- piplelined DIF r2 
// 
#include "methods.typ"
// Disable chapter numbering
// #show heading.where(level: 1): it => {
//   set align(center + top)
//   pagebreak(weak: true)
//   block[
//     #v(0.5cm)
//     #text(size: fontsizes.chap, weight: "bold")[#it.body]
//     #v(1cm)
//   ]
// }

// #showFooter("none")
// #showHeader(false)
// #bibliography("bib.yaml", style: "ieee", title: [References])
// #include "appendix.typ"
