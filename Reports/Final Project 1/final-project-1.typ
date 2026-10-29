#import "settings.typ": *
#show: settings
#outline(
  title: [List of contents],
  target: heading,
  depth: 3
)

#addToPDFBookmark("List of Figures", outlined: true)
#outline(
  title: [List of Figures],
  target: figure.where(kind: image),
)

#addToPDFBookmark("List of Tables", outlined: true)
#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)

#isChap.update(x => true);
#include "intro.typ"
#include "methods.typ"
#include "synthetic generation.typ"
#isChap.update(x => false);
#bibliography("bib.yaml", title: [References])