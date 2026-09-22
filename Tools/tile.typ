#set text(size: 12pt, font: "Nimbus Roman")
#align(center + horizon)[
#set page( margin: (x: 2cm, y:3cm))
#counter(page).update(28);
#set page(numbering: "1")
// #text(size: 24pt)[*Appendix - 1:\ Reference Paper*]
// #pagebreak()
//   #for i in range(1, 11) {
//     block(
//       image("paper/" + str(i) + ".svg", width: 100%),
// //       stroke: 1pt,
//     )
//   }
#heading(level: 1, numbering: none)[Appendix - 2: Presentation Slides]
#let nl = (0,);
  #grid(
    columns: 2,
    row-gutter: 10pt,
    column-gutter: -15pt,
    ..for i in range(1, 22) {
      if (not nl.contains(i)) {(
        rotate(-90deg, reflow: true)[
          #block(
              image("slide/" + str(i) + ".svg", width: 11.2cm),
            stroke: .5pt,
          ),
        ],
      )}
    }
  )
]