#import "settings.typ": *
#show: settings

#include "cover.typ"
#set page(margin: 1.3in)
#include "certificate.typ"
#include "acknowledgment.typ"
#include "abstract.typ"

#set page(numbering: "i");
#include "tocloft.typ"
#set page(margin: (
  left: 1.3in,
  right: 1.1in,
  top: 1.1in,
  bottom: 1.2in,
),
footer: context {
  text(size: 10pt)[
          _Division of Electronics Engg, SOE, CUSAT_
          #h(1fr)
          #counter(page).display()
        ]
},
header: context {
  let current-page = here().page()
  let has-heading = query(heading.where(level: 1)).any(it => it.location().page() == current-page)
  if counter(heading).get().first() > 0 and not has-heading [
    #text(size: 10pt, )[#report-name]
  ]
}
)

#set page(numbering: "1")
#counter(page).update(1)
#isChap.update(x => true);
#include "intro.typ"
#include "methods.typ"
#include "results.typ"
#isChap.update(x => false);
#pagebreak();
#bibliography("bib.yaml", title: [References])



#pagebreak();
#set page(
  footer: context {
    align(center)[
  #text(size: 10pt)[
          #counter(page).display()
        ]]
}
)
#heading(level: 1, numbering: none)[Appendix]
#counter(heading).update(1)
#heading(level: 2, numbering: "A.1")[Source code]

#box(
  width: 100%,
  stroke: 1pt,
  inset: 20pt,
)[
#align(center)[
  MATLAB implementations of the algorithms are available in \
  #link("https://github.com/roopeshor/Radar-Signal-Processing", text(weight: "bold", font: "Fira Mono")[` https://github.com/roopeshor/Radar-Signal-Processing `])
  // #v(10pt)
  // An implementation in #box(inset: (y: -2.5pt, left: -1.5pt))[#image("images/julia.png", height: 13pt)] programming language is also being worked on: \
  // #link("https://github.com/roopeshor/Radar.jl", text(weight: "bold", font: "Fira Mono")[` https://github.com/roopeshor/Radar.jl `])
]]