#import "settings.typ": *
#show: settings

#include "cover.typ"
#set page(margin: 1.3in)
#include "certificate.typ"
#include "acknowledgment.typ"
#include "abstract.typ"

#set page(numbering: "i");
#include "tocloft.typ"
#set page(
  margin: (
    left: 1.2in,
    right: 1.1in,
    top: 1.2in,
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
      #text(size: 9pt, style: "italic")[#report-name]
    ]
  },
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


#include "appendix.typ"
