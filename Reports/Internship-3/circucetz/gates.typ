#import "@preview/cetz:0.5.2"
#import "utils.typ": *

#let or-gate(x, y, w: 1, h: .5, ipy: .6, ipx: .2) = {
  let a = (0, -h)
  let b = (w / 2, -h * 4 / 5)
  let c = (w, 0)
  let d = (w / 2, h * 4 / 5)
  let e = (0, h)
  let f = (w / 5, 0)
  // first leg
  let leg1y = 0 - h + h * ipy
  let legx = w * .18
  let leg2y = -leg1y
  let tx = x + ipx
  let ty = y + -leg1y
  let dr = {
    import cetz.draw: *
    translate(x: tx, y: ty)
    arc-through(a, b, c)
    arc-through(c, d, e)
    arc-through(e, f, a)
    translate(x: -tx, y: -ty)
  }

  return (
    draw: dr,
    p1: (legx + tx, leg1y + ty),
    p2: (legx + tx, leg2y + ty),
    p3: (c.at(0) + tx, c.at(1) + ty),
    _p1: pty(legx + tx, leg1y + ty),
    _p2: pty(legx + tx, leg2y + ty),
    _p3: pty(c.at(0) + tx, c.at(1) + ty),
  )
}

#let and-gate(x, y, w: .7, h: .6, ipy: .22, ipx: .2) = {
  let a = (0, -h / 2)
  let b = (w - h / 2, -h / 2)
  let c = (w, 0)
  let d = (w - h / 2, h / 2)
  let e = (0, h / 2)
  // first leg
  let leg1y = 0 - h / 2 + h * ipy
  let legx = 0
  let leg2y = -leg1y
  let tx = x + ipx
  let ty = y + -leg1y
  let dr = {
    import cetz.draw: *
    translate(x: tx, y: ty)
    line(d, e, a, b)
    arc-through(b, c, d)
    translate(x: -tx, y: -ty)
  }
	
  return (
    draw: dr,
    p1: (legx + tx, leg1y + ty),
    p2: (legx + tx, leg2y + ty),
    p3: (c.at(0) + tx, c.at(1) + ty),
    _p1: pty(legx + tx, leg1y + ty),
    _p2: pty(legx + tx, leg2y + ty),
    _p3: pty(c.at(0) + tx, c.at(1) + ty),
  )
}
