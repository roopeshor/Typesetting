#pagebreak()
#align(center + horizon)[
  #grid(
    columns: 2,
		column-gutter: -53pt,
    ..for i in range(1, 26) {
      (
        block(
          rotate(-90deg, reflow: true)[
            #image("slide/" + str(i) + ".svg", height: 81%),
          ],
          // stroke: .5pt,
					// clip: true,
					// inset: -10pt,
        ),
      )
    }
  )]
