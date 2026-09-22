#pagebreak()
#align(center + horizon)[

#{
  show heading: none
  heading(level: 1, numbering: none)[Appendix - 1: Reference Paper]
}
#text(size: 24pt)[*Appendix - 1:\ Reference Paper*]
#pagebreak()
  #for i in range(1, 11) {
    block(
      image("paper/" + str(i) + ".svg"),
//       stroke: 1pt,
    )
  }
#pagebreak()
#heading(level: 1, numbering: none)[Appendix - 2: Presentation Slides]
  #grid(
    columns: 2,
    row-gutter: 10pt,
    ..for i in range(1, 34) {
			if (i != 2) {
      (
        rotate(-90deg, reflow: true)[
          #block(
              image("slide/" + str(i) + ".svg", width: 11.6cm),
            stroke: .5pt,
          ),
        ],
      )}
    }
  )
]