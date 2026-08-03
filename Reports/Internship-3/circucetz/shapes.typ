#import "@preview/cetz:0.5.2"
#import "utils.typ": *

#let defaults = (
	block: (
		port-padding: .15,
		port-rotation: 0deg
	)
)

#let parse-port-symbol(sym) = {
  let props = (
    clocked: false,
    negated: false,
  )
  if sym.contains(">") { props.clocked = true }
  if sym.contains("o") { props.negated = true }
  return props
}

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
    w: size * cell-width,
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
  let ports = (:)
  let dr
  let a = ystart
  let b = yend
  let c = b - h-size / 2 * skewness
  let d = a + h-size / 2 * skewness
  let sw1 = pty(x + w-size / 2, (yend + c) / 2 + y)
  let sw2 = pty(x + w-size / 2, (ystart + d) / 2 + y)
  let portprefix = 1
  if (invert) {
    ystart = -h-size / 2
    yend = +h-size / 2
    a = ystart
    b = yend
    c = b - h-size / 2 * skewness
    d = a + h-size / 2 * skewness
    dr = {
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
        if (inp-pos-reverse) {
          ports += (
            "p" + str(i): (x, -yx + ty),
            "_p" + str(i): pty(x, -yx + ty),
          )
        } else {
          ports += (
            "p" + str(i): (x, yx + ty),
            "_p" + str(i): pty(x, yx + ty),
          )
        }
      }
      if (inp-pos-reverse) { scale(y: -1) }
      translate(x: -tx, y: -ty)
    }
  } else {
    dr = {
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

        if (inp-pos-reverse) {
          ports += (
            "p" + str(i): (x, -yx + ty),
            "_p" + str(i): pty(x, -yx + ty),
          )
        } else {
          ports += (
            "p" + str(i): (x, yx + ty),
            "_p" + str(i): pty(x, yx + ty),
          )
        }
      }
      if (inp-pos-reverse) { scale(y: -1) }
      translate(x: -tx, y: -ty)
    }
  }
  let outy = y + (ystart + yend) / 2
  if (inp-pos-reverse) { outy = y - (ystart + yend) / 2 }
  ports += (
    out: (x + w-size, outy),
    _sw1: sw1,
    _sw2: sw2,
    sw1: (sw1.x, sw1.y),
    sw2: (sw2.x, sw2.y),
    _out: pty(x + w-size, outy),
  )
  return (
    draw: dr,
    ports: ports,
  )
}

#let bf_skel(x, y, w: 1, h: 1, x-off: .2) = {
  import cetz.draw: *

  let x2 = x + w + x-off * 2
  let midx2 = x + (x2 - x) * .6
  let y2 = y + h
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
  return (
    draw: dy,
    p1: (x, y),
    p2: (x, y2),
    p3: (x2, y),
    p4: (x2, y2),
    _p1: pty(x, y),
    _p2: pty(x, y2),
    _p3: pty(x2, y),
    _p4: pty(x2, y2),
  )
}

#let switcher(x, y, w: 1, h: 1, off: .4, switch: "cross", txtsize: 7pt) = {
  import cetz.draw: *
  let y2 = y + h
  let x2 = x + w + off * 2
  let x3 = x + w + off * 1.5
  let x4 = x3 + off / 2
  let unconnected-stroke = (dash: "dashed", thickness: .5pt, paint: gray)
  let dr = {
    rect((x, y - off / 2), (x2, y2 + off / 2))
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
  return (
    draw: dr,
    p1: (x, y),
    p2: (x, y + h),
    p3: (x2, y),
    p4: (x2, y + h),
    _p1: pty(x, y),
    _p2: pty(x, y + h),
    _p3: pty(x2, y),
    _p4: pty(x2, y + h),
  )
}

// orientation: h/v
#let wedge(x, y, w, h, orientation: "h") = {
  if (orientation == "h") {
    cetz.draw.line(
      (x, y),
      (x, y - h / 2),
      (x + w, y),
      (x, y + h / 2),
      close: true,
    )
  } else {
    cetz.draw.line(
      (x, y),
      (x - w / 2, y),
      (x, y + h),
      (x + w / 2, y),
      close: true,
    )
  }
}

#let block(
  x,
  y,
  name: "",
  name-anchor: "center",
  name-padding: .15,
  w: 1.2,
  h: 1,
  ports: (
    left: (
      // (name: "sd", id: "sd")
    ),
    right: (),
  ),
  fill: rgb("#0000"),
  radius: 0,
  origin-port: "",
  clk-w: .4,
  clk-h: .2,
  port-padding: none,
  port-rotation: none,
) = {
  let fill-color = fill
	if (port-padding == none) {
		port-padding = defaults.block.port-padding
	}
	if (port-rotation == none) {
		port-rotation = defaults.block.port-rotation
	}
	let name-content = name
	if type(name) == str {
		name-content = align(center)[#text(font: "Source Sans 3", weight: "bold")[#name]]
	}
  import cetz.draw: *
  let port-locations = (:)
  let port-list = ()
  let port-anchors = (:)
  let port-names = (:)
  let port-symbols = (:)
  let port-paddings = (:)
  let port-rotations = (:)
  let dr = {
    let bl = (x: 0, y: 0)
    let br = (x: w, y: 0)
    let tl = (x: 0, y: h)
    let tr = (x: w, y: h)

    let side-pos = (
      west: (a: tl, b: bl),
      north: (a: tl, b: tr),
      east: (a: tr, b: br),
      south: (a: bl, b: br),
    )

    for dir in ports.keys() {
      if not (dir in CARDINAL_DIRS) {
        panic("Given dir: " + dir + " is not a cardinal direction")
      }

      let stuff = ports.at(dir)
      if (stuff.len() > 0) {
        let bounds = side-pos.at(dir)
        let dx = (bounds.b.x - bounds.a.x) / (stuff.len() + 1)
        let dy = (bounds.b.y - bounds.a.y) / (stuff.len() + 1)
        for i in range(stuff.len()) {
          let pt = stuff.at(i)
          let p = (bounds.a.x + dx * (i + 1), bounds.a.y + dy * (i + 1))
          port-locations += (pt.id: p)
          port-list += (pt.id,)
          port-anchors += (pt.id: dir)
          if "name" in pt {
            port-names += (pt.id: pt.name)
          }
          if "symbol" in pt {
            port-symbols += (pt.id: pt.symbol)
          }
          if "padding" in pt {
            port-paddings += (pt.id: pt.padding)
          } else {
            port-paddings += (pt.id: port-padding)
          }
          if "rotation" in pt {
            port-rotations += (pt.id: pt.rotation)
          } else {
            port-rotations += (pt.id: port-rotation)
          }
        }
      }
    }
    let tx = x
    let ty = y
    if (origin-port != "") {
      tx -= port-locations.at(origin-port).at(0)
      ty -= port-locations.at(origin-port).at(1)
    }

    rect(
      (bl.x + tx, bl.y + ty),
      (tr.x + tx, tr.y + ty),
      name: "shell",
      radius: radius,
      fill: fill-color,
    )

    for port-id in port-list {
      let p = port-locations.at(port-id)
      p = (
        p.at(0) + tx,
        p.at(1) + ty,
      )
      port-locations.at(port-id) = p
      port-locations += ("_" + port-id: ptyp(p))
      let p-anchor = port-anchors.at(port-id)
      if port-id in port-symbols {
        let s = parse-port-symbol(port-symbols.at(port-id))
        if s.clocked {
          if (p-anchor == "west") {
            wedge(..p, clk-w, clk-h, orientation: "h")
            p = (p.at(0) + clk-w, p.at(1))
          } else if (p-anchor == "east") {
            wedge(..p, -clk-w, clk-h, orientation: "h")
            p = (p.at(0) - clk-w, p.at(1))
          } else if (p-anchor == "north") {
            wedge(..p, clk-w, -clk-h, orientation: "v")
            p = (p.at(0), p.at(1) + clk-h)
          } else if (p-anchor == "south") {
            wedge(..p, clk-w, clk-h, orientation: "v")
            p = (p.at(0), p.at(1) + clk-h)
          }
        }
      }

      if port-id in port-names {
        content(
          p,
          port-names.at(port-id),
          anchor: p-anchor,
          padding: port-paddings.at(port-id),
					angle: port-rotations.at(port-id)
        )
      }
    }

    content(
      "shell."+name-anchor,
      name-content,
      anchor: name-anchor,
      padding: name-padding,
    )
  }

  return (draw: dr, ports: port-locations)
}

#let io-pin(x, y, name: "", w: .3, h: .5, txtpos: "east", padx: .2) = {
  import cetz.draw: *
  let dr = {
    line(
      (x, y - h / 2),
      (x, y + h / 2),
      (x + w, y),
      close: true,
      fill: black,
      name: "w1",
    )
    if (name != "") {
      content("w1", name, anchor: txtpos, padding: padx)
    }
  }
  return (draw: dr, p1: (x, y), p2: (x + w, y), _p1: pty(x, y), _p2: pty(x + w, y))
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



#let Dff(
  x,
  y,
  name: "",
  name-anchor: "north",
  name-padding: .1,
  w: 1,
  h: .75,
	port-padding: .07,
  clk-pos: "north",
) = {
  let port-list = (
    west: (
      (id: "D", name: "D"),
    ),
    east: (
      (id: "Q", name: "Q"),
    ),
  )
  if clk-pos == "north" {
    port-list += (north: ((id: "clk", symbol: ">"),))
  } else {
    port-list += (south: ((id: "clk", symbol: ">"),))
  }

  return block(
    x,
    y,
    name: name,
    name-anchor: name-anchor,
    name-padding: name-padding,
    ports: port-list,
    origin-port: "D",
		port-padding: port-padding,
    fill: gray.transparentize(50%),
    clk-w: .4,
    clk-h: .2,
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
  let scaffold = block(
    x,
    y,
		name: `Counter`,
		name-anchor: "south",
    ports: (
      east: (
        (id: "p1"),
        (id: "p2"),
      ),
    ),
  )
  let dr = {
    import cetz.draw: *
    let mmc = memcell(
      size,
      x,
      y + rh / 2,
      cell-height: cell-height,
      cell-width: cell-width,
      stroke-color: stroke-color,
      contents: contents,
      txtsize: txtsize,
    )
    mmc.draw
    scaffold.draw
  }
  return (
    draw: dr,
    ports: scaffold.ports,
  )
}

#let Dff_en(
  x,
  y,
  name: "",
  name-anchor: "north",
  name-padding: .5,
	port-padding: .1,
  w: 1.5,
  h: 1,
  clk-pos: "north",
) = {
  let port-list = (
    west: (
      (id: "dm"),
      (id: "D", name: "D"),
    ),
    east: (
      (id: "dm"),
      (id: "Q", name: "Q"),
    ),
  )
  if clk-pos == "north" {
    port-list += (
      north: (
        (id: "clk", symbol: ">"),
        (id: "dm"),
        (id: "en", name: `en`, padding: -.3),
      ),
    )
  } else {
    port-list += (
      south: (
        (id: "clk", symbol: ">"),
        (id: "dm"),
        (id: "en", name: `en`),
      ),
    )
  }

  return block(
    x,
    y,
    w: w,
    h: h,
    ports: port-list,
		port-padding: port-padding,
    origin-port: "D",
    fill: gray.transparentize(50%),
    clk-w: .4,
    clk-h: .2,
  )
}
