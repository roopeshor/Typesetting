// #pagebreak()
// #heading(level: 1, numbering: none)[Appendix - 2: Paper]
// #v(-30pt)
// #align(center + horizon)[
//   #for i in range(1, 11) {
//     block(
//       image("paper/" + str(i) + ".svg"),
//       stroke: 1pt,
//     )
//   }
// ]
#pagebreak()
#heading(level: 1, numbering: none)[Appendix - 1: Presentation Slides]
#align(center + horizon)[
  #grid(
    columns: 2,
		row-gutter: 10pt,
    ..for i in range(1, 34) {
			if (i != 2) {
      (
        block(
          rotate(-90deg, reflow: true)[
            #image("slide/" + str(i) + ".svg", height: 82%),
          ],
          stroke: .5pt,
					// clip: true,
					// inset: -10pt,
        ),
      )}
    }
  )]
