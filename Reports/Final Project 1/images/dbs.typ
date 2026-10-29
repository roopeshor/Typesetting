#import "@preview/cetz:0.5.3"

#let dbs-fig = {
  set text(font: "PT Sans", size: 10pt)
  cetz.canvas(length: 20pt, {
  import cetz.draw: *

  // Palette and line styles.
  let ink = rgb("#252525")
  let grey = rgb("#686868")
  let red = rgb("#c51f2b")
  let projection = (paint: grey, thickness: 0.95pt, dash: "dashed")
  let dots = (paint: ink, thickness: 1.15pt, dash: "dotted")
  let red-vector = (paint: red, thickness: 1.0pt)
  let U-vector = (paint: rgb("#0caa08"), thickness: 1.5pt)
  let black-arrow = (end: ">", fill: ink, stroke: ink, length: 0.20cm, width: 0.16cm)
  let red-arrow = (end: ">", fill: red, stroke: none, length: 0.32cm, width: 0.20cm)
  let U-arrow = (end: ">", fill: rgb("#0caa08"), length: 0.22cm, width: 0.20cm)

  // Reference points on the oblique horizontal plane.
  // The four cubic Béziers form a skewed ellipse matching the source image.
  let south = (3.2, 5.85)
  let east = (1.35, 7.05)
  let north = (-3.2, 6.25)
  let west = (-1.35, 5.05)
  let centre = (0, 6.05)

  // Downward projection rays from the ground origin O to the plane.
  line((0, 0), north, stroke: projection)
  line((0, 0), west, stroke: projection)
  line((0, 0), east, stroke: projection)
  line((0, 0), south, stroke: projection)
  
  line(centre, north, stroke: projection)
  line(centre, west, stroke: projection)
  line(centre, east, stroke: projection)
  line(centre, south, stroke: projection)
  line((0, 0), (0, 7.95), stroke: projection)

  // Ground-plane reference axes. Arrowheads follow the directions in the image.
  line((-2.48, -1.78), (2.82, 2.02),
    stroke: (paint: ink, thickness: 1.45pt), mark: black-arrow)
  line((4.25, -0.62), (-3.78, 0.55),
    stroke: (paint: ink, thickness: 1.45pt), mark: black-arrow)

  // Oblique ellipse: South -> East -> North -> West -> South.
  bezier(south, east,
    (3.9456, 6.4023), (3.116, 6.9395),
    stroke: (paint: ink, thickness: 1pt))
  bezier(east, north,
    (-0.416, 7.1605), (-2.4544, 6.8023),
    stroke: (paint: ink, thickness: 1pt))
  bezier(north, west,
    (-3.9456, 5.6977), (-3.116, 5.1605),
    stroke: (paint: ink, thickness: 1pt))
  bezier(west, south,
    (0.416, 4.9395), (2.4544, 5.2977),
    stroke: (paint: ink, thickness: 1pt))

  // The four red components in the plane.
  line(centre, (-1.02, 7.08), stroke: U-vector, mark: U-arrow)
  line(centre, (-1.76, 6.16), stroke: red-vector, mark: red-arrow)
  line(centre, (0.96, 6.74), stroke: red-vector, mark: red-arrow)
  line(centre, (0, 7.36), stroke: red-vector, mark: red-arrow)

  // Zenith arrow, extending above the red vertical vector.
  line((0, 7.34), (0, 7.97),
    stroke: (paint: ink, thickness: 1pt), mark: black-arrow)

  // Angle markers. `anchor: "origin"` places each arc's centre at its coordinate.
  arc((0, 0), start: 62deg, stop: 89deg, radius: 0.93,
    anchor: "origin", stroke: (paint: ink, thickness: 1.0pt))

  // Cardinal / reference labels.
  content((0, 8.18), text(size: .9em, weight: "bold")[#text[Zenith]], anchor: "south")
  content(north, text(size: .9em, weight: "bold")[North], anchor: "east", padding: 6pt)
  content(south, text(size: .9em, weight: "bold")[South], anchor: "west", padding: 6pt)
  content((east), text(size: .9em, weight: "bold")[East], anchor: "south", padding: 4pt)
  content(west, text(size: .9em, weight: "bold")[West], anchor: "north-east", padding: 2pt)

  // Italic vector and axis labels.
  content((-1.43, 7.28), text(size: 1em, style: "italic")[$U$], anchor: "west")
  content((0.12, 6.69), text(size: 1em, style: "italic")[$w$], anchor: "west")
  content((-1.65, 6.60), text(size: 1em, style: "italic")[$v$], anchor: "west")
  content((0.91, 6.48), text(size: 1em, style: "italic")[$u$], anchor: "west")
  content((0.43, 1.56), text(size: .9em, style: "italic")[$phi.alt$], anchor: "west")
  content((2.73, 1.50), text(size: 1em, style: "italic")[$x$], anchor: "west")
  content((-3, 0), text(size: 1em, style: "italic")[$y$], anchor: "west")
})
}