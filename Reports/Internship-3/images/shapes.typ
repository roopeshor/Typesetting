#import "@preview/cetz:0.5.2"

#let pty(x, y) = { (x: x, y: y) }
#let ptyp(a) = { (x: a.at(0), y: a.at(1)) }
#let memcell(
  size,
  x,
  y,
  cell-height: .3,
  cell-width: .3,
  stroke-color: black,
  contents: (),
  txtsize: 10pt,
  center-align: false,
  name: "",
  name-anchor: "south",
  fill-color: white,
) = {
  let p1x = x
  let p2x = x + size * cell-width
  let dr = {
    import cetz.draw: *
    if (center-align) {
      x += -size * cell-width / 2
      p1x = x
      p2x = x + size * cell-width
    }
    for i in range(1, size + 1) {
      let x1 = x + cell-width * (i - 1)
      let y1 = y - cell-height / 2
      let x2 = x + cell-width * i
      let y2 = y + cell-height / 2
      rect((x1, y1), (x2, y2), stroke: stroke-color, fill: fill-color)
      if (contents.len() == size) {
        let mx = (x1 + x2) / 2
        let my = (y1 + y2) / 2
        content((mx, my), text(size: txtsize)[#contents.at(i - 1)])
      }
    }
    content(((p1x + p2x) / 2, y), name, anchor: name-anchor, padding: .25)
  }
  return (
    draw: dr,
    p1: (p1x, y),
    p2: (p2x, y),
    _p1: pty(x, y),
    _p2: pty(x + size * cell-width, y),
    width: size * cell-width,
  )
}

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

#let counter(
  size,
  x,
  y,
  cell-height: .3,
  cell-width: .3,
  stroke-color: black,
  contents: (),
  txtsize: 10pt,
  rh: 1,
  name: "",
) = {
  let mmc = memcell(
    size,
    x,
    y,
    cell-height: cell-height,
    cell-width: cell-width,
    stroke-color: stroke-color,
    contents: contents,
    txtsize: txtsize,
  )
  let dr = {
    import cetz.draw: *
    rect((x, y - rh / 2), (rel: (mmc.width, rh)))
    content((x + mmc.width / 2, y - rh / 2), name, anchor: "south", padding: .1)

    // scale(50%)
    // translate(x: mmc.width / 2, y: rh)
    mmc.draw
    // translate(x: -mmc.width / 2, y: -rh)
    // scale(200%)
  }
  return (
    draw: dr,
    p2: (x + mmc.width, y),
    _p2: pty(x + mmc.width, y),
    p1: (x, y),
    _p1: pty(x, y),
  )
}

#let mux(
  x,
  y,
  inps: (),
  h-size: 1.3,
  y-offset: .4,
  w-size: .5,
  skewness: .6,
  font-size: 8pt,
  x-padding: .08,
  invert: false,
  inp-pos-reverse: false,
) = {
  import cetz.draw: *
  let N = calc.max(inps.len(), 2)
  let yspace = (h-size - 2 * y-offset) / (N - 1)
  let tx = x
  let ty = y
  let ystart = -y-offset
  let yend = +h-size - y-offset
  let inp_pos = ()
  let drawn
  let a = ystart
  let b = yend
  let c = b - h-size / 2 * skewness
  let d = a + h-size / 2 * skewness
  let sw1 = pty(x + w-size / 2, (yend + c) / 2 + y)
  let sw2 = pty(x + w-size / 2, (ystart + d) / 2 + y)
  if (invert) {
    ystart = -h-size / 2
    yend = +h-size / 2
    a = ystart
    b = yend
    c = b - h-size / 2 * skewness
    d = a + h-size / 2 * skewness
    drawn = {
      translate(x: tx, y: ty)
      if (inp-pos-reverse) { scale(y: -1) }
      line(
        (0, d),
        (0, c),
        (w-size, b),
        (w-size, a),
        close: true,
        fill: gray.lighten(80%),
      )
      for i in range(0, inps.len()) {
        let yx = ystart + y-offset + i * yspace
        content((-x-padding + w-size, yx), anchor: "east", text(size: font-size)[#inps.at(
          i,
        )])
        if (inp-pos-reverse) { inp_pos.push(-yx + ty) } else { inp_pos.push(yx + ty) }
      }
      if (inp-pos-reverse) { scale(y: -1) }
      translate(x: -tx, y: -ty)
    }
  } else {
    drawn = {
      translate(x: tx, y: ty)
      if (inp-pos-reverse) {
        scale(y: -1)
        sw1 = pty(x + w-size / 2, y - (a + d) / 2)
        sw2 = pty(x + w-size / 2, y - (b + c) / 2)
      }
      line(
        (0, a),
        (0, b),
        (w-size, c),
        (w-size, d),
        close: true,
        stroke: 1pt,
        fill: gray.lighten(80%),
      )
      for i in range(0, inps.len()) {
        let yx = i * yspace
        content((x-padding, yx), anchor: "west", text(size: font-size)[#inps.at(i)])

        if (inp-pos-reverse) { inp_pos.push(-yx + ty) } else { inp_pos.push(yx + ty) }
      }
      if (inp-pos-reverse) { scale(y: -1) }
      translate(x: -tx, y: -ty)
    }
  }
  let outy = y + (ystart + yend) / 2
  if (inp-pos-reverse) { outy = y - (ystart + yend) / 2 }
  return (
    draw: drawn,
    inp_pos: inp_pos,
    x: x,
    sw1: (sw1.x, sw1.y),
    _sw1: sw1,
    sw2: (sw2.x, sw2.y),
    _sw2: sw2,
    out: (x + w-size, outy),
    _out: pty(x + w-size, outy),
  )
}

#let bf_skel_old(x, y, h-space, v-space, x-off: .2) = {
  import cetz.draw: *

  let x2 = x + h-space + x-off * 2
  let midx2 = x + (x2 - x) * .6
  let y2 = y + v-space
  let dy = {
    line((x + x-off, y), (x2 - x-off, y2))
    line((x + x-off, y2), (x2 - x-off, y))

    line((x, y), (x2, y))
    line((x, y2), (midx2, y2), mark: (end: "straight"), name: "ln")
    line((x, y2), (x2, y2))

    content(
      "ln.90%",
      anchor: "north",
      padding: 2pt,
      text($-1$, size: 7pt),
    )
  }
  return (dy, x, y, x, y2, x2, y, x2, y2)
}

#let bf_skel(x, y, h-space: 1, v-space: 1, x-off: .2) = {
  let bf = bf_skel_old(x, y, h-space, v-space, x-off: x-off)
  return (
    draw: bf.at(0),
    p1: (bf.at(1), bf.at(2)),
    p2: (bf.at(3), bf.at(4)),
    p3: (bf.at(5), bf.at(6)),
    p4: (bf.at(7), bf.at(8)),
    _p1: pty(bf.at(1), bf.at(2)),
    _p2: pty(bf.at(3), bf.at(4)),
    _p3: pty(bf.at(5), bf.at(6)),
    _p4: pty(bf.at(7), bf.at(8)),
  )
}

#let switcher(x, y, h-space, v-space, off: .4, switch: "cross", txtsize: 7pt) = {
  import cetz.draw: *
  let y2 = y + v-space
  let x2 = x + h-space + off * 2
  let x3 = x + h-space + off * 1.5
  let x4 = x3 + off / 2
  let unconnected-stroke = (dash: "dashed", thickness: .5pt, paint: gray)
  let dr = {
    rect((x + off / 2, y - off / 2), (x3, y2 + off / 2))
    if (switch == "cross") {
      line((x + off / 2, y), (x3, y2))
      line((x + off / 2, y2), (x3, y))
    } else {
      line((x + off / 2, y), (x3, y2), stroke: unconnected-stroke)
      line((x + off / 2, y2), (x3, y), stroke: unconnected-stroke)
    }

    let midx2 = x + (x2 - x) * .6
    line((x, y), (x + off / 2, y))
    line((x, y2), (x + off / 2, y2))

    line((x3, y), (x4, y))
    line((x3, y2), (x4, y2))

    if (switch == "cross") {
      line((x, y), (x2, y), stroke: unconnected-stroke)
      line((x, y2), (x2, y2), stroke: unconnected-stroke)
    } else {
      line((x, y), (x2, y))
      line((x, y2), (x2, y2))
    }
    content(((x + x2) / 2, y2 + off), text(size: txtsize)[commutator])
  }
  return (dr, x, y, x, y + v-space, x4, y, x4, y + v-space)
}

#let Dff_old(x, y, name, w: 1, h: .75) = {
  import cetz.draw: *
  let dr = {
    translate(x: x, y: y)

    rect((0, -h / 2), (w, h / 2), fill: maroon.transparentize(90%))
    content((w / 2, -h / 2), name, anchor: "south", padding: .05)

    content((0, 0), text(size: 8pt)[D], anchor: "west", padding: .05)
    content((w, 0), text(size: 8pt)[Q], anchor: "east", padding: .05)
    line(
      (w / 2, h / 2 - .2),
      (w / 2 - .2, h / 2),
      (w / 2 + .2, h / 2),
      close: true,
    )

    translate(x: -x, y: -y)
  }
  return (dr, x, y, x + w, y)
}

#let Dff(x, y, name: ``, w: 1, h: .75) = {
  import cetz.draw: *
  let dr = {
    translate(x: x, y: y)

    rect((0, -h / 2), (w, h / 2), fill: maroon.transparentize(90%))
    content((w / 2, -h / 2), name, anchor: "south", padding: .05)

    content((0, 0), text(size: 8pt)[D], anchor: "west", padding: .05)
    content((w, 0), text(size: 8pt)[Q], anchor: "east", padding: .05)
    line(
      (w / 2, h / 2 - .2),
      (w / 2 - .2, h / 2),
      (w / 2 + .2, h / 2),
      close: true,
    )

    translate(x: -x, y: -y)
  }
  return (
    draw: dr,
    p1: (x, y),
    p2: (x + w, y),
    _p1: pty(x, y),
    _p2: pty(x + w, y),
  )
}
#let Dff_en(x, y, name, w: 1.3, h: .8) = {
  import cetz.draw: *
  let ext = .3
  let eyt = .15
  let en_pos = (-ext + w / 2, h / 2 + eyt)
  let dr = {
    translate(x: x, y: y)

    rect((0, -h / 2 + eyt), (rel: (w, h)), fill: maroon.transparentize(90%))

    content((w / 2, -h / 2 + eyt), name, anchor: "south", padding: .05)

    content((0, 0), text(size: 8pt)[D], anchor: "west", padding: .1)
    content((w, 0), text(size: 8pt)[Q], anchor: "east", padding: .1)
    line(
      (ext + w / 2, h / 2 - .2 + eyt),
      (ext + w / 2 - .15, h / 2 + eyt),
      (ext + w / 2 + .15, h / 2 + eyt),
      close: true,
    )
    content(en_pos, text(size: 8pt)[G], anchor: "south", padding: .1)
    en_pos = (en_pos.at(0) + x, en_pos.at(1) + y)
    translate(x: -x, y: -y)
  }
  return (
    draw: dr,
    p1: (x, y),
    p2: (x + w, y),
    _p1: pty(x, y),
    _p2: pty(x + w, y),
    en: en_pos,
    _en: ptyp(en_pos),
  )
}


#let block_old(x, y, name, w: 1.2, h: 1) = {
  import cetz.draw: *
  let dr = {
    translate(x: x, y: y)
    rect((0, -h / 2), (w, h / 2))
    content((w / 2, 0), name)
    translate(x: -x, y: -y)
  }
  return (dr, x, x + w, y)
}

#let block(
  x,
  y,
  name,
  w: 1.2,
  h: 1,
  ports: (
    left: (
      // (name: "sd", side: "left/right")
    ),
    right: (),
  ),
  py: .3,
  mpy: .2,
) = {
  import cetz.draw: *
  let retList = (ports: (:))
  let dr = {
    translate(x: x, y: y)
    rect((0, -h / 2), (w, h / 2))
    if (ports.right.len() > 0 or ports.left.len() > 0) {
      content((w / 2, -h / 2), name, anchor: "north", padding: .1)
    } else {
      content((w / 2, 0), name)
    }
    let ly = -h / 2 + py + mpy

    let lydy = (h - py * 2) / calc.max(1, ports.left.len())
    let idx = 1
    for i in range(0, ports.left.len()) {
      retList.ports += (
        ports.left.at(i).id: (0 + x, ly + i * lydy + y),
      )
      retList.ports += (
        "_" + ports.left.at(i).id: pty(0 + x, ly + i * lydy + y),
      )
      content(
        (0, ly + i * lydy),
        ports.left.at(i).name,
        anchor: "west",
        padding: .1,
      )
      idx += 1
    }
    lydy = (h - py * 2) / calc.max(1, ports.right.len() - 1)
    for i in range(0, ports.right.len()) {
      retList.ports += (
        ports.right.at(i).id: (w + x, ly + i * lydy + y),
      )
      retList.ports += (
        "_" + ports.right.at(i).id: pty(w + x, ly + i * lydy + y),
      )
      content(
        (w, ly + i * lydy),
        ports.right.at(i).name,
        anchor: "east",
        padding: .1,
      )
      idx += 1
    }
    translate(x: -x, y: -y)
  }
  retList += (draw: dr)
  return retList
}



#let wedge_old(x, y, txt: "", w: .3, h: .5, txtpos: "east", padx: .2) = {
  import cetz.draw: *
  let dy = {
    line(
      (x, y - h / 2),
      (x, y + h / 2),
      (x + w, y),
      close: true,
      fill: black,
      name: "w1",
    )
    if (txt != "") {
      content("w1", txt, anchor: txtpos, padding: padx)
    }
  }
  return (dy, x, y, x + w, y)
}
#let wedge(x, y, txt: "", w: .3, h: .5, txtpos: "east", padx: .2) = {
  import cetz.draw: *
  let dy = {
    line(
      (x, y - h / 2),
      (x, y + h / 2),
      (x + w, y),
      close: true,
      fill: black,
      name: "w1",
    )
    if (txt != "") {
      content("w1", txt, anchor: txtpos, padding: padx)
    }
  }
  return (draw: dy, p1: (x, y), p2: (x + w, y), _p1: pty(x, y), _p2: pty(x + w, y))
}

#let joint(p, r: 1.5pt) = {
  cetz.draw.circle(p, radius: r, fill: black)
}


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

#let zigzagv_get_corner(a, b, ratio: .5, stroke: "") = {
  let dx = (b.at(0) - a.at(0)) * ratio

  let c1 = (a.at(0) + dx, a.at(1))
  let c2 = (a.at(0) + dx, b.at(1))
  let dr = {
		if (stroke != ""){
			cetz.draw.line(a, c1, c2, b, stroke:stroke)
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

#let zigzagv_with_corner(a, b, c) = {
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

#let zigzagv(a, b, ratio: .5, stroke: "") = {
  let zwc = zigzagv_get_corner(a, b, ratio: ratio, stroke: stroke)
  return zwc.draw
}

#let zigzagv_corner(a, b, c) = {
  let zwc = zigzagv_with_corner(a, b, c)
  return zwc.draw
}
#let wire(a, b) = {
  cetz.draw.line(a, b)
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
    // arc-through(a, b, c)
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

#let Label(p, label, r: .3) = {
  let (x, y) = p
  let dr = {
    cetz.draw.circle(p, radius: r)
    cetz.draw.content(p, text(size: 6pt)[#label])
  }

  return (
    draw: dr,
    p1: (x - r, y),
    p2: (x, y - r),
    p3: (x + r, y),
    p4: (x, y + r),
    _p1: pty(x - r, y),
    _p2: pty(x, y - r),
    _p3: pty(x + r, y),
    _p4: pty(x, y + r),
  )
}
