#import "@preview/cetz:0.5.2"
#import "../drawing.typ": *

#let a = text(fill: red)[$a$]
#let b = text(fill: green)[$b$]
#let c = text(fill: blue)[$c$]
#let d = text(fill: purple)[$d$]


#let memcell(size, x, y, cell-height: .3, cell-width: .3, stroke-color: black, contents: ()) = {
  import cetz.draw: *
  for i in range(1, size + 1) {
    let x1 = x + cell-width * (i - 1)
    let y1 = y - cell-height / 2
    let x2 = x + cell-width * i
    let y2 = y + cell-height / 2
    rect((x1, y1), (x2, y2), stroke: stroke-color)
    if (contents.len() == size) {
      let mx = (x1 + x2) / 2
      let my = (y1 + y2) / 2
      content((mx, my), contents.at(i - 1))
    }
  }
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
) = {
  import cetz.draw: *
  let N = calc.max(inps.len(), 1)
  let yspace = (h-size - 2 * y-offset) / (N - 1)
  let ystart = y - y-offset
  let yend = y + h-size - y-offset
  let inp_pos = ()
  let drawn
  if (invert) {
    let ystart = y - h-size / 2
    let yend = y + h-size / 2
    drawn = {
      line(
        (x, ystart + h-size / 2 * skewness),
        (x, yend - h-size / 2 * skewness),
        (x + w-size, yend),
        (x + w-size, ystart),
        close: true,
        fill: gray.lighten(80%),
      )
      for i in range(0, inps.len()) {
        let yx = ystart + y-offset + i * yspace
        content((x - x-padding + w-size, yx), anchor: "east", text(size: font-size)[#inps.at(
          i,
        )])
        inp_pos.push(yx)
      }
    }
  } else {
    drawn = {
      line(
        (x, ystart),
        (x, yend),
        (x + w-size, yend - h-size / 2 * skewness),
        (x + w-size, y - y-offset + h-size / 2 * skewness),
        (x, y - y-offset),
        // close: true,
        stroke: 1pt,
        fill: gray.lighten(80%),
      )
      for i in range(0, inps.len()) {
        let yx = y + i * yspace
        content((x + x-padding, yx), anchor: "west", text(size: font-size)[#inps.at(i)])
        inp_pos.push(yx)
      }
    }
  }
  return (drawn, inp_pos)
}

#let bf_skel(x, y, h-space, v-space, x-off: .2) = {
  import cetz.draw: *

  line((x + x-off, y), (x + h-space + x-off, y + v-space))
  line((x + x-off, y + v-space), (x + h-space + x-off, y))

  let x2 = x + h-space + x-off * 2
  let midx2 = x + (x2 - x) * .6
  line((x, y), (x2, y))
  line((x, y + v-space), (midx2, y + v-space), mark: (end: "straight"), name: "ln")
  line((x, y + v-space), (x2, y + v-space))

  content(
    "ln.90%",
    anchor: "north",
    padding: 5pt,
    text($-1$, size: 7pt),
  )
}

#let switcher(x, y, h-space, v-space, off: .4, switch: "cross`") = {
  import cetz.draw: *
  let y2 = y + v-space
  rect((x + off / 2, y - off / 2), (x + h-space + off * 1.5, y2 + off / 2))
  if (switch == "cross") {
    line((x + off / 2, y), (x + h-space + off * 1.5, y2))
    line((x + off / 2, y2), (x + h-space + off * 1.5, y))
  } else {
    line((x + off / 2, y), (x + h-space + off * 1.5, y2), stroke: (dash: "dashed", thickness: .5pt))
    line((x + off / 2, y2), (x + h-space + off * 1.5, y), stroke: (dash: "dashed", thickness: .5pt))
  }

  let x2 = x + h-space + off * 2
  let midx2 = x + (x2 - x) * .6
  line((x, y), (x + off / 2, y))
  line((x, y2), (x + off / 2, y2))

  let x3 = x + h-space + off * 1.5
  line((x3, y), (x3 + off / 2, y))
  line((x3, y2), (x3 + off / 2, y2))

  if (switch == "cross") {
    line((x, y), (x2, y), stroke: (dash: "dashed", thickness: .5pt))
    line((x, y2), (x2, y2), stroke: (dash: "dashed", thickness: .5pt))
  } else {
    line((x, y), (x2, y))
    line((x, y2), (x2, y2))
  }
  content(((x + x2) / 2, y2 + off), text(size: 7pt)[commutator])
}

#let R2MDC_4unit(values) = {
  import cetz.draw: *
  let (x1, y1) = values.at(0).pos
  let (x2, y2) = values.at(0).pos
  let cellh = .6
  content((x1 - .5, y1), values.at(0).ins, anchor: "east", padding: .1)
  line((x1 - .5, y1), (x1, y1))
  let rx1 = x1
  let ry1 = y1
  let st = mux(
    x1,
    y1,
    invert: true,
    inps: ($0$, $1$),
    w-size: .5,
    h-size: 1.5,
  )
  st.at(0)
  x1 += .5
  x2 += .5
  (y1, y2) = st.at(1)


  let bfvs = y2 - y1
  let tx1 = x1
  let l1w = .3
  line((x1, y1), (x1 + l1w, y1))
  x1 += l1w
  x2 += l1w
  let cw1 = .4

  ///// stage 0
  content((x2 + bfvs, y2), values.at(1).bottom-leg, anchor: "north", padding: .1)

  memcell(2, x1, y1, cell-height: cellh, cell-width: cw1, contents: values.at(1).shr-content)
  x1 += cw1 * 2
  x2 += cw1 * 2

  if (values.at(0).show-stages) {
    rect((rx1 - .15, y1 - .6), (x1 + .15, y1 + 1.4), fill: purple.transparentize(90%), stroke: 0.1pt)
    content(((rx1 + x1) / 2, y1 - .7), text(size: 7pt, fill: purple)[Input delay], anchor: "south")
  }
  rx1 = x1
  ry1 = y1

  line((tx1, y2), (x1 + .5, y2))
  let bf-off = .2
  let bfhs = .7
  bf_skel(x1, y1, bfhs, bfvs, x-off: bf-off)

  x1 += bfhs + bf-off * 2
  x2 += bfhs + bf-off * 2

  let c1r = .25
  let tx1 = x1
  let ty1 = y1
  x1 += c1r
  x2 += c1r

  circle((x2, y2), radius: c1r)
  content((x2, y2), text(size: 6pt)[$W_4$])
  x2 += c1r
  x1 += c1r

  let l2w = .3
  line((x2, y2), (x2 + l2w, y2))
  x1 += l2w
  x2 += l2w

  let cw2 = 1.5

  content((x1 + cw2 / 2, y1), values.at(1).bf-top-right, anchor: "south", padding: .1)

  memcell(1, x2, y2, cell-height: cellh, cell-width: cw2, contents: values.at(1).bf-bottom-shr)
  x1 += cw2
  x2 += cw2
  line((tx1, ty1), (x2, ty1))
  switcher(x1, y1, bfhs / 2, bfvs, off: .5, switch: values.at(1).cross)
  x1 += bfhs / 2 + .5 * 2
  x2 += bfhs / 2 + .5 * 2
  tx1 = x1
  ty1 = y1

  let cw1 = 1
  memcell(1, x2, y1, cell-height: .45, contents: values.at(2).shr-content, cell-width: cw1)
  x1 += cw1
  x2 += cw1

  ///// stage 1
  if (values.at(0).show-stages) {
    rect((rx1 + .15, ry1 - .6), (x1 + .1, y1 + 1.4), fill: teal.transparentize(90%), stroke: 0.1pt)
    content(((rx1 + x1) / 2, ry1 - .7), text(size: 7pt, fill: rgb("#088"))[Stage 0], anchor: "south")
    rx1 = x1
    ry1 = y1
  }

  content(((x1 + tx1) / 2, y2), values.at(2).bottom-leg, anchor: "north", padding: .1)
  line((tx1, y2), (x1, y2))
  bf_skel(x1, y1, bfhs, bfvs, x-off: bf-off)
  x1 += bfhs + bf-off * 2
  x2 += bfhs + bf-off * 2

  tx1 = x1
  tx1 = x1
  ty1 = y1
  let c1r = .25
  x1 += c1r
  x2 += c1r
  circle((x2, y2), radius: c1r)
  content((x2, y2), text(size: 6pt)[$W_2$])
  x2 += c1r
  x1 += c1r

  if (values.at(0).show-stages) {
    rect((rx1 + .1, ry1 - .6), (x1 + .15, y1 + 1.4), fill: orange.transparentize(90%), stroke: 0.1pt)
    content(((rx1 + .3 + x1) / 2, ry1 - .7), text(size: 7pt, fill: orange.darken(50%))[Stage 1], anchor: "south")
  }

  line((tx1, y1), (x1 + .5, y1))
  line((x2, y2), (x2 + .5, y2))
  x1 += .5
  x2 += .5
  content((x1, y1), values.at(3).outputs.at(0), anchor: "west", padding: .1)
  content((x2, y2), values.at(3).outputs.at(1), anchor: "west", padding: .1)
}

#let R2MDC_4 = cetz.canvas({
  import cetz.draw: *
  let W40 = text(size: 8pt)[$W_4^0$]
  let W42 = text(size: 8pt)[$W_4^2$]
  let values = (
    (
      (ins: $#d #h(2pt) #c #h(2pt) #b #h(2pt) #a$, show-stages: true),
      (
        // stage 0	starting from delay block
        shr-size: .5,
        shr-content: ($$, $$),
        bottom-leg: "",
        bf-top-right: "",
        bf-bottom-shr: ("",),
        cross: "straight",
      ),
      (
        // stage 1	starting from delay block
        shr-size: 1,
        shr-content: ($$,),
        bottom-leg: "",
        bf-top-right: "",
        bf-bottom-shr: ("",),
      ),
      (
        outputs: ("", ""),
      ),
    ),
    (
      (ins: $#d #h(2pt) #c #h(2pt) #b$, show-stages: false),
      (
        // stage 0	starting from delay block
        shr-size: .5,
        shr-content: ($#a$, $$),
        bottom-leg: "",
        bf-top-right: "",
        bf-bottom-shr: ("",),
        cross: "straight",
      ),
      (
        // stage 1	starting from delay block
        shr-size: 1,
        shr-content: ($$,),
        bottom-leg: "",
        bf-top-right: "",
        bf-bottom-shr: ("",),
      ),
      (
        outputs: ("", ""),
      ),
    ),
    (
      (ins: $#d #h(2pt) #c$, show-stages: false),
      (
        // stage 0	starting from delay block
        shr-size: .5,
        shr-content: ($#b$, $#a$),
        bottom-leg: $$,
        bf-top-right: $a$,
        bf-bottom-shr: ("",),
        cross: "straight",
      ),
      (
        // stage 1	starting from delay block
        shr-size: 1,
        shr-content: ($$,),
        bottom-leg: "",
        bf-top-right: "",
        bf-bottom-shr: ("",),
      ),
      (
        outputs: ("", ""),
      ),
    ),
    (
      (ins: $#d$, show-stages: false),
      (
        // stage 0	starting from delay block
        shr-size: .5,
        shr-content: ($#b$, $#a$),
        bottom-leg: $#c$,
        bf-top-right: $#a + #c$,
        bf-bottom-shr: ("",),
        cross: "straight",
      ),
      (
        // stage 1	starting from delay block
        shr-size: 1,
        shr-content: ($a$,),
        bottom-leg: "",
        bf-top-right: "",
        bf-bottom-shr: ("",),
      ),
      (
        outputs: ("", ""),
      ),
    ),
    (
      (ins: $$, show-stages: false),
      (
        // stage 0	starting from delay block
        shr-size: .5,
        shr-content: ($$, $#b$),
        bottom-leg: $#d$,
        bf-top-right: $#b + #d$,
        bf-bottom-shr: ($#a - #c$,),
        cross: "cross",
      ),
      (
        // stage 1	starting from delay block
        shr-size: 1,
        shr-content: ($#a + #c$,),
        bottom-leg: $#b + #d$,
        bf-top-right: "",
        bf-bottom-shr: ($$,),
      ),
      (
        outputs: (
          $(#a + #c) + (#b + #d)$,
          $(#a + #c) - (#b + #d)$,
        ),
      ),
    ),
    (
      (ins: $$, show-stages: false),
      (
        // stage 0	starting from delay block
        shr-size: .5,
        shr-content: (),
        bottom-leg: $$,
        bf-top-right: $$,
        bf-bottom-shr: ($(#b - #d)j$,),
        cross: "straight",
      ),
      (
        // stage 1	starting from delay block
        shr-size: 1,
        shr-content: ($#a - #c$,),
        bottom-leg: $(#b - #d)j$,
        bf-top-right: "",
        bf-bottom-shr: ($$,),
      ),
      (
        outputs: (
          $(#a - #c) + (#b - #d)j$,
          $(#a - #c) - (#b - #d)j$,
        ),
      ),
    ),
  )
  scale(y: -1)
  stroke(.7pt)
  content((-1.9, 1), [#underline[*cycle*]])
  let cy = 0
  for i in range(0, values.len()) {
    cy += 2.2
    values.at(i).at(0).pos = (0, cy)
    content((-1.9, cy), [#i:])
    R2MDC_4unit(values.at(i))
    if (i == 0 and values.at(0).at(0).show-stages) {
      cy += .5
    }
  }
});

#let R2MDC_4_signalflow = cetz.canvas({
  import cetz.draw: *
  let h-scale = 2
  let v-scale = 1
  _draw-fft(
    is-dit: false,
    N: 4,
    h-scale: h-scale,
    v-scale: v-scale,
    bf-gap: 2.5,
    show-twiddle: false,
    remove-last-pad: true,
    in-labels: (a, b, c, d),
    out-labels: (
      $(#a + #c) + (#b + #d)$,
      $(#a + #c) - (#b + #d)$,
      $(#a - #c) + (#b - #d)j$,
      $(#a - #c) - (#b - #d)j$,
    ),
  )
  let middle = (
    $(#a + #c)$,
    $(#b + #d)$,
    $(#a - #c)$,
    $(#b - #d)j$,
  )
  for i in range(0, middle.len()) {
    content((h-scale, v-scale * i - .3), padding: 4pt, anchor: "west", middle.at(i))
  }
})

