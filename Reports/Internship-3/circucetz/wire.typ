#import "@preview/cetz:0.5.2"
#import "utils.typ": *

#let joint(p, r: 1.5pt) = {
  let dr = cetz.draw.circle(p, radius: r, fill: black)
  return (draw: dr)
}

#let zigzagv(a, b, ratio: .5, stroke: "") = {
  let dx = (b.at(0) - a.at(0)) * ratio

  let c1 = (a.at(0) + dx, a.at(1))
  let c2 = (a.at(0) + dx, b.at(1))
  let dr = {
    if (stroke != "") {
      cetz.draw.line(a, c1, c2, b, stroke: stroke)
    } else {
      cetz.draw.line(a, c1, c2, b)
    }
  }

  return (
    draw: dr,
    c1: c1,
    c2: c2,
    _c1: ptyp(c1),
    _c2: ptyp(c2),
  )
}

#let L-wire(a, b, stroke: "") = {
  let c1 = (b.at(0), a.at(1))
  let dr = {
    if (stroke != "") {
      cetz.draw.line(a, c1,b, stroke: stroke)
    } else {
      cetz.draw.line(a, c1,b)
    }
  }

  return (
    draw: dr,
    c1: c1,
    _c1: ptyp(c1),
  )
}

#let zigzagv_corner(a, b, c) = {
  let c1 = (c.at(0), a.at(1))
  let c2 = (c.at(0), b.at(1))
  let dr = {
    import cetz.draw: line
    line(a, c1, c2, b)
  }

  return (
    draw: dr,
    c1: c1,
    c2: c2,
    _c1: ptyp(c1),
    _c2: ptyp(c2),
  )
}

#let wire(a, b) = {
  cetz.draw.line(a, b)
}
