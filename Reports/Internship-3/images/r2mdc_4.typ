#import "@preview/cetz:0.5.2"
#import "../drawing.typ": *
#import "colors.typ": *
// #import "@preview/circuiteria:0.2.0"

#let R2MDC_stage(
  buffer,
  x,
  y,
  stage-height: 1,
  memcw1: .35,
  memcw2: 1.5,
  params: (),
  show-stages: false,
  stage-color: rgb("#49c6e5"),
  stage: 0,
  txtsize: 10pt,
) = {
  let x1 = 0 // left upper pin
  let y1 = 0 // left upper pin
  let x2 = 0 // left lower pin
  let y2 = stage-height // left lower pin
  let x3 = 0 // right upper pin
  let y3 = 0 // right upper pin
  let x4 = 0 // right lower pin
  let y4 = stage-height // right lower pin
  let padx = .3
  let dr = {
    import cetz.draw: *
    import "../circucetz/lib.typ": *
    translate(x: x, y: y)
    let cellh = .5
    let mmc1 = memcell(buffer, x1, y1, cell-height: cellh, cell-width: memcw1, contents: params.shr-content)
    mmc1.draw

    content((mmc1._p2.x / 2, y2), text(size: txtsize)[#params.bottom-leg], anchor: "north", padding: .1)

    let rx1 = x1
    let ry1 = y1

    let bf-off = .2
    let bfhs = .7
    let bf1 = bf_skel(mmc1._p2.x + .2, mmc1._p2.y, w: bfhs, h: stage-height, x-off: bf-off)
    bf1.draw


    line((mmc1._p2.x, mmc1._p2.y), bf1.p1)
    line((x2, y2), bf1.p2)

    let c1r = .25
    let tx1 = x1
    let ty1 = y1

    x4 = bf1._p3.x
    x3 = bf1._p3.x
    x3 += .3
    x4 += .3

    line((bf1._p3.x, y4), (x4 - c1r, y4))
    circle((x4, y4), radius: c1r)
    content((x4, y4), text(size: 6pt)[$W_(#calc.pow(2, buffer))$])
    x4 += c1r
    x3 += c1r

    let l2w = .5
    let cw2 = 1.5


    let stage1x
    if (buffer != 1) {
      let mmc2 = memcell(
        int(buffer / 2),
        x4 + l2w,
        y4,
        cell-height: cellh,
        cell-width: memcw2,
        contents: params.bf-bottom-shr,
      )
      mmc2.draw

      content(
        ((mmc2._p1.x + mmc2._p2.x) / 2, y1),
        text(size: txtsize)[#params.bf-top-right],
        anchor: "south",
        padding: .1,
      )
      line((x4, y4), mmc2.p1)
      x3 = mmc2._p2.x + .3
      x4 = mmc2._p2.x + .3
      let sww1 = switcher(x3, y1, w:bfhs / 2, h:stage-height, off: .5, switch: params.cross)
      sww1.draw

      x3 = sww1._p3.x + padx
      x4 = sww1._p3.x + padx

      line((bf1._p3.x, bf1._p3.y), (sww1._p1.x, sww1._p1.y))
      line(mmc2.p2, sww1.p2)
      stage1x = (sww1._p3.x + x3) / 2
    } else {
      x3 = x4
      stage1x = x3 + padx
      line(
        (bf1._p3.x, bf1._p3.y),
        (x4 + padx, y3),
      )
      line(
        (x4, y4),
        (x4 + padx, y4),
      )
      x4 += padx
      x3 += padx
    }


    if (show-stages) {
      rect((-.15, -.6), (stage1x, +1.4), fill: stage-color.transparentize(90%), stroke: 0.1pt)
      content(
        ((rx1 + x3) / 2, ry1 - .7),
        text(size: txtsize - 2pt, fill: stage-color.darken(50%))[Stage #stage],
        anchor: "south",
      )
    }
    translate(x: -x, y: -y)
  }
  x1 += x
  y1 += y
  x2 += x
  y2 += y
  x3 += x
  y3 += y
  x4 += x
  y4 += y
  return (dr, x1, y1, x2, y2, x3 - padx, y3, x4 - padx, y4)
}

#let R2MDC_4unit(values) = {
  import cetz.draw: *
  import "../circucetz/lib.typ": *
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
  st.draw
  x1 += .5
  x2 += .5
  y1 = st.ports._p0.y
  y2 = st.ports._p1.y

  if (values.at(0).show-stages) {
    rect((rx1 - .15, y1 - .6), (x1 + .15, y1 + 1.4), fill: purple.transparentize(90%), stroke: 0.1pt)
    content(((rx1 + x1) / 2, y1 - .7), text(size: 7pt, fill: purple.darken(50%))[Controller], anchor: "south")
  }

  let bfvs = y2 - y1
  let tx1 = x1
  let l1w = .3

  x1 += l1w
  x2 += l1w

  ///// stage 0

  let s1 = R2MDC_stage(
    2,
    x1,
    y1,
    stage-height: bfvs,
    params: values.at(1),
    show-stages: values.at(0).show-stages,
    stage-color: stage-1-color,
    stage: 0,
  )
  s1.at(0)

  line(
    (x1 - l1w, y1),
    (s1.at(1), s1.at(2)),
  )
  line(
    (x2 - l1w, y2),
    (s1.at(3), s1.at(4)),
  )
  ///// stage 1
  let s2 = R2MDC_stage(
    1,
    s1.at(5) + .3,
    s1.at(6),
    memcw1: 1,
    stage-height: bfvs,
    params: values.at(2),
    show-stages: values.at(0).show-stages,
    stage-color: stage-2-color,
    stage: 1,
  )

  s2.at(0)

  line(
    (s1.at(5), s1.at(6)),
    (s2.at(1), s2.at(2)),
  )
  line(
    (s1.at(7), s1.at(8)),
    (s2.at(3), s2.at(4)),
  )
  let x3 = s2.at(5)
  let y3 = s2.at(6)
  let x4 = s2.at(7)
  let y4 = s2.at(8)

  content((x3 + .3, y3), text(size: 10pt)[#values.at(3).outputs.at(0)], anchor: "west", padding: .1)
  content((x4 + .3, y4), text(size: 10pt)[#values.at(3).outputs.at(1)], anchor: "west", padding: .1)
  // line((s2.at(5), s2.at(6)), (rel: (.5, 0)))
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
    in-labels: ($x_0 = #a$, $x_1 = #b$, $x_2 = #c$, $x_3 = #d$),
    out-labels: (
      $X_0 = (#a + #c) + (#b + #d)$,
      $X_2 = (#a + #c) - (#b + #d)$,
      $X_1 = (#a - #c) + (#b - #d)j$,
      $X_3 = (#a - #c) - (#b - #d)j$,
    ),
  )
  let middle = (
    $x'_0 = #a + #c$,
    $x'_1 = #b + #d$,
    $x'_2 = #a - #c$,
    $x'_3 = (#b - #d) j$,
  )
  for i in range(0, middle.len()) {
    content((h-scale, v-scale * i - .3), padding: 4pt, anchor: "west", middle.at(i))
  }
})

#let ckt-r2mdc-stage = {
  cetz.canvas({
    import cetz.draw: *
    import "../circucetz/lib.typ": *

    scale(y: -1)

    //////////// Input pins

    let in_valid = io-pin(0, 0, name: `in_valid`)
    let in0 = io-pin(0, 1.5, name: `in0`)
    let in1 = io-pin(0, 3, name: `in1`)
    let in_ctr = io-pin(0, 4.5, name: `in_ctr`)

    in_valid.draw
    in0.draw
    in1.draw
    in_ctr.draw

    /////////// stage 1
    let mmc1 = memcell(4, in0._p1.x + 1, in0._p1.y)
    let bf1 = bf_skel(
      mmc1._p2.x + .7,
      mmc1._p2.y,
      w: 1,
      h: 1.5,
      x-off: 0,
    )

    mmc1.draw
    bf1.draw

    // connections
    line(in0.p1, mmc1.p1)
    line(in1.p1, bf1.p2)
    line(mmc1.p2, bf1.p1)


    ////////// stage 2
    let r_bf0 = Dff(bf1._p3.x + .8, bf1._p3.y, name: `r_bf0`, name-anchor: "south")
    let r_bf1 = Dff(r_bf0.ports._D.x, bf1._p4.y, name: `r_bf1`, name-anchor: "south")
    let r1_ctr = Dff(r_bf0.ports._D.x, in_ctr._p1.y, name: `r1_ctr`, name-anchor: "south")
    let r_valid1 = Dff(r_bf0.ports._D.x, in_valid._p1.y, name: `r_valid1`, name-anchor: "south")

    r_bf0.draw
    r_bf1.draw
    r1_ctr.draw
    r_valid1.draw

    line(bf1.p4, r_bf1.ports.D)
    line(bf1.p3, r_bf0.ports.D)
    line(in_ctr.p2, r1_ctr.ports.D)
    line(in_valid.p2, r_valid1.ports.D)

    ////////// stage 3

    let idxgen = block(
      r1_ctr.ports._Q.x + .8,
      r1_ctr.ports._Q.y,
      w: 1.5,
      name: align(center)[
        #text(size: 9pt, font: "Noto Mono")[Idx\ Gen]
      ],
      ports: (
        west: ((id: "p1"),),
        east: ((id: "p2"),),
      ),
			origin-port: "p1"
    )

    let tw = block(
      idxgen.ports._p2.x + .5,
      idxgen.ports._p2.y,
      w: 1.5,
      name: align(center)[
        #text(size: 9pt, font: "Noto Mono")[Twiddle\ ROM]
      ],
      ports: (
        west: ((id: "p1"),),
        east: ((id: "p2"),),
      ),
			origin-port: "p1"
    )

    let ppl1 = pipelined_multiplier(
      tw.ports._p2.x + .5,
      r_bf1.ports._D.y,
    )

    tw.draw
    idxgen.draw
    ppl1.draw

    line(r1_ctr.ports.Q, idxgen.ports.p1)
    line(idxgen.ports.p2, tw.ports.p1)
    line(r_bf1.ports.Q, ppl1.p1)
    L-wire(tw.ports.p2, ppl1.p2).draw

    ///////// Stage 5

    let r2_bf0 = Dff(ppl1._clk.x, r_bf0.ports._D.y, name: `r2_bf0`, name-anchor: "south")
    let r2_ctr = Dff(ppl1._clk.x, r1_ctr.ports._D.y + 1, name: `r2_ctr`, name-anchor: "south")
    let r_valid2 = Dff(ppl1._clk.x, r_valid1.ports._D.y, name: `r_valid2`, name-anchor: "south")

    r2_bf0.draw
    r2_ctr.draw
    r_valid2.draw

    line(r_bf0.ports.Q, r2_bf0.ports.D)
    line(r_valid1.ports.Q, r_valid2.ports.D)
    let zw1 = zigzagv(r1_ctr.ports.Q, r2_ctr.ports.D, ratio: .07)
    zw1.draw
    joint(zw1.c1).draw


    //////// stage 6

    let mmc2 = memcell(2, ppl1._out.x + .6, ppl1._out.y)
    let mmc3 = memcell(2, mmc2._p1.x, r2_ctr.ports._D.y)
    let mmc4 = memcell(2, mmc2._p1.x, r_valid2.ports._D.y)

    let sww1 = switcher(
      mmc2._p2.x + .3,
      r2_bf0.ports._D.y,
      w: .7,
      h: calc.abs(r2_bf0.ports._D.y - mmc2._p2.y),
      txtsize: 10pt,
    )

    mmc2.draw
    mmc3.draw
    mmc4.draw
    sww1.draw


    line(ppl1.out, mmc2.p1)
    line(r2_bf0.ports.Q, sww1.p1)
    line(mmc2.p2, sww1.p2)

    //////// output side

    let outx = sww1._p3.x + 1

    let out0 = io-pin(outx, sww1._p3.y, name: `out0`, txtpos: "west", padx: .3)
    let out1 = io-pin(outx, sww1._p2.y, name: `out1`, txtpos: "west", padx: .3)
    let out_cnt = io-pin(outx, mmc3._p1.y, name: `out_cnt`, txtpos: "west", padx: .3)
    let out_valid = io-pin(outx, mmc4._p1.y, name: `out_valid`, txtpos: "west", padx: .3)

    out0.draw
    out1.draw
    out_cnt.draw
    out_valid.draw

    line(r2_ctr.ports.Q, mmc3.p1)
    line(r_valid2.ports.Q, mmc4.p1)
    line(sww1.p3, out0.p1)
    line(sww1.p4, out1.p1)
    line(mmc3.p2, out_cnt.p1)
    line(mmc4.p2, out_valid.p1)

    let borderx2 = out_valid._p1.x
    let bordery2 = out_cnt._p1.y + 1

    rect((0, -1.5), (borderx2, bordery2))
  })
}
