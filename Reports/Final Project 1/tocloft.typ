#import "settings.typ": *
#outline(
  title: [List of contents],
  target: heading,
  depth: 3,
)
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
