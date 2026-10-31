/*  */#import "settings.typ": *
#show: settings

#set page(margin: 1.3in)
#include "cover.typ"
#include "certificate.typ"
#include "acknowledgment.typ"
#include "abstract.typ"

#outline(
  title: [List of contents],
  target: heading,
  depth: 3
)
#set page(numbering: "i");
#counter(page).update(1);

#pagebreak();
#addToPDFBookmark("List of Figures", outlined: true)
#outline(
  title: [List of Figures],
  target: figure.where(kind: image),
)
#pagebreak();
#addToPDFBookmark("List of Tables", outlined: true)
#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)
#set page(margin: (
  left: 1.3in,
  right: 1.1in,
  top: 1.1in,
  bottom: 1.2in,
))

#pagebreak();
#isChap.update(x => true);
#set page(numbering: "1")
#counter(page).update(1)
#include "intro.typ"
#include "methods.typ"
#include "results.typ"
#isChap.update(x => false);
#pagebreak();
#bibliography("bib.yaml", title: [References])



#pagebreak();
#heading(level: 1, numbering: none)[Appendix]
#counter(heading).update(1)
#heading(level: 2, numbering: "A.1")[Source code]

#box(
  width: 100%,
  stroke: 1pt,
  inset: 20pt,
)[
#align(center)[
  MATLAB implementation of algorithm are available in \
  #link("https://github.com/roopeshor/Radar-Signal-Processing", text(weight: "bold", font: "Fira Mono")[` https://github.com/roopeshor/Radar-Signal-Processing `])
  // #v(10pt)
  // An implementation in #box(inset: (y: -2.5pt, left: -1.5pt))[#image("images/julia.png", height: 13pt)] programming language is also being worked on: \
  // #link("https://github.com/roopeshor/Radar.jl", text(weight: "bold", font: "Fira Mono")[` https://github.com/roopeshor/Radar.jl `])
]]