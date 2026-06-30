#import "@preview/cetz:0.5.2"
#import "utils.typ": *

#let pipelined_multiplier(x, y) = {
  let p1
  let p2
  let clk
  let out
  let dr = {
    import cetz.draw: *
    translate(x: x, y: y)
    let ax = 0 //
    let ay = 0 //
    let bx = ax
    let by = ay - .5
    let mh = 1.5
    let mw = 2.5
    rect((0, -mh / 2), (rel: (mw, mh)), name: "mulr", fill: yellow.transparentize(70%))
    content((mw, -mh / 2 + .2), text(size: 8pt)[`multiplier`], anchor: "east", padding: .1)
    let cx = .5
    let cy = 0
    let r = .25
    p1 = (cx + x - r, cy + y)
    p2 = (cx + x, y + r)

    circle((cx, cy), radius: r)
    content((cx, cy), $times$)
    let rh = .6
    let rw = .4
    let rx = .6

    let rbx = cx + rx
    let rby = cy + rh / 2

    rect((rbx, cy - rh / 2), (rbx + rw, rby))
    line((cx + r, cy), (rbx, cy), name: "l2")
    line(
      (((rbx) + rbx + rw) / 2, rby - .2),
      (((rbx) + rbx + rw) / 2 - rw / 3, rby),
      (((rbx) + rbx + rw) / 2 + rw / 3, rby),
      close: true,
    )

    clk = (
      x + ((rbx) + rbx + rw) / 2,
      y + rby,
    )
    line((cx + rx + rw, cy), (cx + rx + rw + .6 - r, cy), name: "l2")
    cx += rx + rw + .6
    circle((cx, cy), radius: r)
    content((cx, cy), $+$)
    cx += r
    out = (cx + x, cy + y)

    let mulx = cx + ax
    let muly = ay

    translate(x: -x, y: -y)
  }
  return (
    draw: dr,
    p1: p1,
    p2: p2,
    clk: clk,
    out: out,
    _p1: ptyp(p1),
    _p2: ptyp(p2),
    _clk: ptyp(clk),
    _out: ptyp(out),
  )
}
