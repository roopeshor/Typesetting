#import "@preview/cetz:0.5.2"
#import "../drawing.typ": *
#import "colors.typ": *
#import "shapes.typ": *
#import "@preview/circuiteria:0.2.0"

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
    translate(x: x, y: y)
    let cellh = .5

    let mmc1 = memcell(buffer, x1, y1, cell-height: cellh, cell-width: memcw1, contents: params.shr-content)
    mmc1.draw

    content((mmc1._p2.x / 2, y2), text(size: txtsize)[#params.bottom-leg], anchor: "north", padding: .1)

    let rx1 = x1
    let ry1 = y1

    let bf-off = .2
    let bfhs = .7
    let bf1 = bf_skel_old(mmc1._p2.x + .2, mmc1._p2.y, bfhs, stage-height, x-off: bf-off)
    bf1.at(0)


    line((mmc1._p2.x, mmc1._p2.y), (bf1.at(1), bf1.at(2)))
    line((x2, y2), (bf1.at(3), bf1.at(4)))

    let c1r = .25
    let tx1 = x1
    let ty1 = y1

    x4 = bf1.at(5)
    x3 = bf1.at(5)
    x3 += .3
    x4 += .3

    line((bf1.at(5), y4), (x4 - c1r, y4))
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
      let sww1 = switcher(x3, y1, bfhs / 2, stage-height, off: .5, switch: params.cross)
      sww1.at(0)

      x3 = sww1.at(5) + padx
      x4 = sww1.at(5) + padx

      line((bf1.at(5), bf1.at(6)), (sww1.at(1), sww1.at(2)))
      line(mmc2.p2, (sww1.at(3), sww1.at(4)))
      stage1x = (sww1.at(5) + x3) / 2
    } else {
      x3 = x4
      stage1x = x3 + padx
      line(
        (bf1.at(5), bf1.at(6)),
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
  (y1, y2) = st.inp_pos

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
		stage: 0
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
		stage: 1
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
    scale(y: -1)
    let x1 = 0
    let y1 = 0
    let x2 = 0
    let y2 = 0
    let inpx = -.6
    let blockx1 = inpx
    let blockpdd = 1
    let blocky1 = -2.7

    let mmc2 = memcell(4, x1, y1)
    mmc2.draw
    // line(
    //   mmc2.p1,
    //   (sww1.at(1), mmc2.at(2)),
    // )

    x1 = mmc2._p2.x + .7
    x2 = mmc2._p2.x + .7


    ///// butterfly
    let bfw = 1
    let bfh = 1.5
    let bfp = .5

    let bf1 = bf_skel_old(x1, y1, bfw, bfh, x-off: 0)
    bf1.at(0)
    x2 = bf1.at(3)
    y2 = bf1.at(4)

    rect((bf1.at(1) - bfp, bf1.at(2) - bfp * 1.2), (bf1.at(5) + bfp * .7, y2 + bfp * 1.4))
    content((bf1.at(1) - bfp / 2, bf1.at(2)), $a$, anchor: "south", padding: 0.1)
    content((bf1.at(1) - bfp / 2, y2), $b$, anchor: "north", padding: 0.1)
    content((bf1.at(5), bf1.at(2)), $c$, anchor: "south", padding: 0.1)
    content((bf1.at(5), y2), $d$, anchor: "north", padding: 0.1)

    let tx1 = x1


    let in0 = wedge_old(inpx, y1, txt: `in0`)
    let in1 = wedge_old(inpx, y2, txt: `in1`)
    in0.at(0)
    in1.at(0)
    line((in0.at(1), in0.at(2)), mmc2.p1)
    line((in1.at(1), in1.at(2)), (bf1.at(3), bf1.at(4)))
    line(mmc2.p2, (bf1.at(1), bf1.at(2)))


    x1 = bf1.at(5) + .8
    y1 = bf1.at(6)

    let r_bf0 = Dff_old(x1, y1, `r_bf0`)
    r_bf0.at(0)
    line((tx1, r_bf0.at(2)), (x1, r_bf0.at(2)))
    let r_bf1 = Dff_old(x1, y1 + 1.5, `r_bf1`)
    r_bf1.at(0)

    line((x2, y2), ((x1 + x2) * .65, y2))
    line(((x1 + x2) * .65, y2), ((x1 + x2) * .65, r_bf1.at(2)))
    line(((x1 + x2) * .65, r_bf1.at(2)), (x1, r_bf1.at(2)))

    let r1_ctr = Dff_old(x1, y1 + 3, `r1_ctr`)
    r1_ctr.at(0)

    let r_valid1 = Dff_old(x1, y1 - 1.5, `r_valid1`)
    r_valid1.at(0)


    /// stage 2
    let idxgen = block_old(
      r1_ctr.at(3) + .5,
      r1_ctr.at(2),
      text(size: 9pt)[`idx
gen`],
      w: .9,
    )
    idxgen.at(0)
    line((r1_ctr.at(3), r1_ctr.at(2)), (idxgen.at(1), idxgen.at(3)))

    let tw = block_old(
      idxgen.at(2) + .3,
      idxgen.at(3),
      text(size: 9pt)[`Twiddle
ROM`],
      w: 1.5,
    )
    tw.at(0)
    line((idxgen.at(2), idxgen.at(3)), (tw.at(1), tw.at(3)))

    let ax = tw.at(2) + .5
    let ay = r_bf1.at(2)
    let bx = ax
    let by = ay - .5
    let mh = 1.5
    let mw = 2.5
    translate(x: ax, y: ay + .3)
    rect((0, -mh / 2), (rel: (mw, mh)), name: "mulr", fill: yellow.transparentize(70%))
    content((mw, mh / 2 - .2), text(size: 10pt)[multiplier], anchor: "east", padding: .1)
    let cx = .5
    let cy = -.3
    let tcx = cx
    circle((cx, cy), radius: .25)
    content((cx, cy), $times$)
    let rh = .6
    let rw = .4
    let rx = .6

    rect((cx + rx, cy - rh / 2), (cx + rx + rw, cy + rh / 2))
    line((cx + .25, cy), (cx + rx, cy), name: "l2")
    line(
      (((cx + rx) + cx + rx + rw) / 2, cy + rh / 2 - .2),
      (((cx + rx) + cx + rx + rw) / 2 - rw / 3, cy + rh / 2),
      (((cx + rx) + cx + rx + rw) / 2 + rw / 3, cy + rh / 2),
      close: true,
    )
    line((cx + rx + rw, cy), (cx + rx + rw + .6 - .25, cy), name: "l2")
    cx += rx + rw + .6
    circle((cx, cy), radius: .25)
    content((cx, cy), $+$)
    cx += .25
    let mulx = cx + ax
    let muly = ay

    translate(x: -ax, y: -ay - .3)
    let dffx = tcx + ax + rx

    line((r_bf1.at(3), r_bf1.at(2)), (ax + tcx - .25, ay), name: "l1")
    line((tw.at(2), tw.at(3)), (ax + tcx, tw.at(3)), name: "l2")
    line((ax + tcx, tw.at(3)), (ax + tcx, ay + .25), name: "l3")
    content("l1.90%", $a$, anchor: "south", padding: .1)
    content("l3.10%", $b$, anchor: "west", padding: .1)


    let r2_bf0 = Dff_old(dffx, r_bf0.at(2), `r2_bf0`)
    r2_bf0.at(0)
    let r2_ctr = Dff_old(dffx, r1_ctr.at(2) + 1, `r2_ctr`)
    r2_ctr.at(0)

    let r_valid2 = Dff_old(dffx, r_valid1.at(2), `r_valid2`)
    r_valid2.at(0)

    line((r_bf0.at(3), r_bf0.at(2)), (r2_bf0.at(1), r_bf0.at(2)))
    line(
      ((r1_ctr.at(3) + idxgen.at(1)) / 2, r1_ctr.at(2)),
      ((r1_ctr.at(3) + idxgen.at(1)) / 2, r2_ctr.at(2)),
    )
    line(
      ((r1_ctr.at(3) + idxgen.at(1)) / 2, r2_ctr.at(2)),
      (r2_ctr.at(1), r2_ctr.at(2)),
    )
    line((r_valid1.at(3), r_valid1.at(2)), (r_valid2.at(1), r_valid1.at(2)))

    //// commmutator
    let commx = mulx + .6
    let commy = muly
    let mmc1 = memcell(2, commx, muly)
    mmc1.draw
    commx = mmc1._p2.x
    line(
      (mulx, muly),
      (mmc1._p1.x, muly),
    )


    let mmc3 = memcell(2, mmc1._p1.x, r2_ctr.at(2))
    mmc3.draw
    let mmc4 = memcell(2, mmc1._p1.x, r_valid2.at(2))
    mmc4.draw


    let swh = commy - r2_bf0.at(2)
    let swx = .3
    let sww = .75
    let sww1 = switcher(commx + swx, r2_bf0.at(2), sww, swh, txtsize: 10pt)
    sww1.at(0)
    line(
      (r2_bf0.at(3), r2_bf0.at(2)),
      (sww1.at(3), r2_bf0.at(2)),
    )
    line(
      (mmc1._p2.x, mmc1._p1.y),
      (sww1.at(1), mmc1._p1.y),
    )
    commx = sww1.at(5) + .3
    commy = sww1.at(6)

    let in_ctr = wedge_old(inpx, r1_ctr.at(2), txt: `in_ctr`)
    in_ctr.at(0)
    let in_valid = wedge_old(inpx, r_valid1.at(2), txt: `in_valid`)
    in_valid.at(0)
    line(
      (inpx, r1_ctr.at(2)),
      (r1_ctr.at(1), r1_ctr.at(2)),
    )
    line(
      (inpx, r_valid1.at(2)),
      (r_valid1.at(1), r_valid1.at(2)),
    )


    let out0 = wedge_old(commx, sww1.at(6), txt: `out0`, txtpos: "west", padx: .3)
    out0.at(0)
    let out1 = wedge_old(commx, sww1.at(4), txt: `out1`, txtpos: "west", padx: .3)
    out1.at(0)
    let out_cnt = wedge_old(commx, mmc3._p1.y, txt: `out_cnt`, txtpos: "west", padx: .3)
    out_cnt.at(0)
    let out_valid = wedge_old(commx, mmc4._p1.y, txt: `out_valid`, txtpos: "west", padx: .3)
    out_valid.at(0)

    line((r2_ctr.at(3), r2_ctr.at(4)), (mmc3._p1.x, mmc3._p1.y))
    line((r_valid2.at(3), r_valid2.at(4)), (mmc4._p1.x, mmc4._p1.y))

    line((sww1.at(5), sww1.at(6)), (out0.at(1), out0.at(2)))
    line((sww1.at(5), sww1.at(8)), (out1.at(1), out1.at(2)))
    line(mmc3.p2, (out_cnt.at(1), out_cnt.at(2)))
    line(mmc4.p2, (out_valid.at(1), out_valid.at(2)))

    let blockx2 = out_valid.at(1)
    let blocky2 = out_cnt.at(2) + blockpdd

    rect((blockx1, blocky1), (blockx2, blocky2))
  })
}
