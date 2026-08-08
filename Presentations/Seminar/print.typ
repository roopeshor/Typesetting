
#set page(
  margin: (top: 1cm, bottom: 1cm),
)
#let ignore = (31,32,33)
#align(center+horizon)[
= Seminar Presentation Slides
#for i in range(1, 34) {
  if not ignore.contains(i) {
    block(image("svg/p_" + str(i) + ".svg", height: 31%), stroke: 1pt)
  }
}
]