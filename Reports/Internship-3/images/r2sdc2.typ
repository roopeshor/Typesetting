#import "@preview/cetz:0.5.2"
#import "colors.typ": *

#let ckt-r2sdc-stage = {
  cetz.canvas({
    import cetz.draw: *
    import "../circucetz/lib.typ": *
    scale(y: -1)
    let x = 0
    let y = 0
    let inpx = -1.2
    let blockx1 = inpx
    let blockpdd = 1
    let blocky1
    let blockx2
    let blocky2

    /// Counter & TWiddle
    let cnt = counter(4, x, y, name: `counter`)
    cnt.draw
    let tw = block(
      cnt.ports._p2.x + 3,
      cnt.ports._p2.y,
      name: text(size: 9pt)[*`Twiddle`*],
      name-anchor: "south",
      w: 1.5,
      h: 1.5,
      ports: (
        west: (
          (id: "state", name: `state`),
          (id: "k", name: `k`),
        ),
        east: (
          (id: "W", name: `W`),
        ),
      ),
      origin-port: "k",
    )

    tw.draw
    line(cnt.ports.p2, tw.ports.k)
    content(cnt.ports.p1, `state`, anchor: "north-west", padding: .1)


    //// DF, Muxers, Shiftr reg
    x = cnt.ports._p2.x
    y = cnt.ports._p1.y - 3
    let bf = bf_skel(x, y, h: 1.2, w: 1.5)
    bf.draw

    let data_shr = memcell(
      8,
      (bf._p1.x + bf._p3.x) / 2,
      bf._p1.y - 1.5,
      center-align: true,
      name: `data_shr`,
    )
    data_shr.draw
    blocky1 = data_shr._p1.y - 1
    zigzagv(data_shr.p1, bf.p1, ratio: -2).draw

    let mux1 = mux(..bf.p3, inps: (`1`, `0`), inp-pos-reverse: true)
    mux1.draw
    let mux2 = mux(..bf.p4, inps: (`0`, `1`))
    mux2.draw


    let din = io-pin(inpx, bf._p2.y, name: `din`)
    din.draw
    wire(din.p2, bf.p2)

    let wcm = L-wire(
      cnt.ports.p2,
      mux2.ports.sw1,
    )
    wcm.draw
    joint(wcm.c1).draw
    zigzagv_corner(cnt.ports.p1, tw.ports.state, wcm.c1).draw


    line(mux1.ports.sw1, mux2.ports.sw2)
    let w1 = zigzagv(bf.p1, mux1.ports.p1, ratio: -.1)
    let w2 = zigzagv(bf.p2, mux2.ports.p1, ratio: -.1)
    joint(w1.c1).draw
    joint(w2.c1).draw
    zigzagv(mux2.ports.out, data_shr.p2, ratio: -3).draw
    w1.draw
    w2.draw

    ///// input validators
    let valid_sr = memcell(8, cnt.ports._p1.x, cnt.ports._p1.y + 2.2, name: `valid_sr`, name-anchor: "north")

    valid_sr.draw
    let in_valid = io-pin(inpx, valid_sr._p1.y, name: `in_valid`)
    in_valid.draw
    line(in_valid.p1, valid_sr.p1)

    let or1 = or-gate(valid_sr._p2.x + 1, valid_sr._p2.y - .7, w: .7, h: .3)
    or1.draw
    let w1 = zigzagv(in_valid.p2, or1.p1, ratio: .1)
    w1.draw
    joint(w1.c1).draw
    w1 = zigzagv(valid_sr.p2, or1.p2)
    w1.draw
    joint(w1.c1).draw

    let ppl = pipelined_multiplier(
      mux1.ports._out.x + 3,
      mux1.ports._out.y,
    )
    ppl.draw
    wire(mux1.ports.out, ppl.p1)
    zigzagv(tw.ports.W, ppl.p2, ratio: 1).draw

    //// last stage
    let pre_stage_en = Dff(
      ppl._clk.x,
      or1._p3.y,
      name: `pre_stage_en`,
      name-anchor: "south",
    )
    pre_stage_en.draw
    wire(or1.p3, pre_stage_en.ports.D)
    content(or1.p3, `stage_en`, anchor: "south-west", padding: .1)
    let dout_ff = Dff_en(ppl._out.x + 1, ppl._out.y, name: `dout_ff`)
    wire(ppl.out, dout_ff.ports.D)
    dout_ff.draw
    zigzagv(pre_stage_en.ports.Q, dout_ff.ports.en, ratio: 1).draw

    let and1 = and-gate(or1._p3.x + 2, or1._p3.y + 1)
    and1.draw

    let w3 = zigzagv(or1.p3, and1.p1, ratio: .8)
    w3.draw
    let jx = joint(w3.c1)
    jx.draw

    zigzagv_corner(valid_sr.p2, and1.p2, w1.c1).draw

    let mul_valid_ff = Dff(
      dout_ff.ports._D.x,
      and1._p3.y,
      name: `mul_valid`,
      name-anchor: "south",
    )

    mul_valid_ff.draw
    wire(and1.p3, mul_valid_ff.ports.D)

    let dout = io-pin(dout_ff.ports._Q.x + 2, dout_ff.ports._Q.y, name: `dout`, txtpos: "west", padx: .3)
    dout.draw
    let out_valid = io-pin(dout._p1.x, mul_valid_ff.ports._Q.y, name: `out_valid`, txtpos: "west", padx: .3)
    out_valid.draw

    wire(dout_ff.ports.Q, dout.p1)
    wire(mul_valid_ff.ports.Q, out_valid.p1)
    blockx2 = out_valid._p1.x
    blocky2 = out_valid._p1.y + 1

    rect(
      (blockx1, blocky1),
      (blockx2, blocky2),
    )
  })
}


#let R2SDC_Stage(
  x,
  y,
  stage,
  mmcell-values: (),
  mmcwidth: 1,
  mmc2width: 1.4,
  mux2-out: "",
  tw-out: "",
  mmcell2-values: (),
  muxsw: false,
) = {
  let p1
  let p2
  let p3
	import "../circucetz/lib.typ": utils.ptyp
  let dr = {
    import cetz.draw: *
    import "../circucetz/lib.typ": *

    let N = calc.pow(2, stage)
    let shr = memcell(
      N,
      x,
      y,
      cell-width: mmcwidth,
      cell-height: .5,
      contents: mmcell-values,
      // fill-color: green.transparentize(90%),
    )
    shr.draw
    let bf = bf_skel(shr._p2.x + .4, shr._p2.y, h: .6, w: .7, x-off: 0)
    bf.draw


    let wlsr-xmin = calc.min(shr._p1.x - .2, bf._p1.x - .2)
    p1 = (wlsr-xmin, bf._p1.y)
    line(shr.p2, bf.p1)
    p2 = (shr._p1.x - .2, bf._p2.y)
    line(bf.p2, p2)
    let bfj1 = (shr._p2.x + .2, bf._p1.y)
    let bfj2 = (shr._p2.x + .2, bf._p2.y)
    let mux1 = mux(
      bf._p3.x + .2,
      bf._p3.y,
      inps: (`1`, `0`),
      inp-pos-reverse: true,
      h-size: .8,
      y-offset: .25,
    )
    let mux2 = mux(
      bf._p4.x + .2,
      bf._p4.y,
      inps: (`0`, `1`),
      h-size: .8,
      y-offset: .25,
    )

    mux1.draw
    mux2.draw

    let shr-r-p1 = (mux1.ports._out.x - .1, shr._p2.y - .7)

    zigzagv(shr-r-p1, mux2.ports.out, ratio: 3).draw
    zigzagv(shr.p1, shr-r-p1, ratio: -.1).draw

    let muxconn1 = (dash: "dashed", thickness: .5pt, paint: gray)
    let muxconn2 = (paint: black)
    if (muxsw) {
      muxconn2 = (dash: "dashed", thickness: .5pt, paint: gray)
      muxconn1 = (paint: black)
      // mux1 is bottom connection to bf
      // mux2 zigzag connection to pre-bf
      let jx = joint(bfj2, r: 1.2pt)
      jx.draw
    } else {
      let jx = joint(bfj1, r: 1.2pt)
      jx.draw
    }
    zigzagv(bfj2, (mux2.ports._p0.x, mux2.ports._p1.y), ratio: 0, stroke: muxconn1).draw
    line(bf.p3, (mux1.ports._p0.x, mux1.ports._p0.y), stroke: muxconn1)
    // stroke with low contrast

    line(bf.p4, (mux2.ports._p0.x, mux2.ports._p0.y), stroke: muxconn2)
    zigzagv(bfj1, (mux1.ports._p0.x, mux1.ports._p1.y), ratio: 0, stroke: muxconn2).draw

    /// mux2-out
    content((shr._p1.x + .7, shr._p2.y - .7), mux2-out, anchor: "south-west", padding: .1)

    x = mux2.ports._out.x + 1
    y = (mux1.ports._out.y + mux2.ports._out.y) / 2

    let tw = Label((x, y), $W_(#N)$)
    tw.draw

    if (N > 1) {
      p3 = (tw._p4.x + 1.3, p2.at(1))
    } else {
      p3 = (tw._p4.x + .5, p2.at(1))
    }
    zigzagv(mux1.ports.out, tw.p2, ratio: 1).draw
    zigzagv(tw.p4, p3, ratio: 0).draw

    content((tw._p4.x - .3, p3.at(1) + .1), tw-out, anchor: "north-west", padding: .1)


    if (N > 1) {
      let shr2 = memcell(
        calc.ceil(N / 2),
        p3.at(0),
        p3.at(1),
        cell-width: mmc2width,
        cell-height: .6,
        contents: mmcell2-values,
        // fill-color: green.transparentize(90%),
      )
      shr2.draw
      p3 = shr2.p2
    }
  }
  return (
    draw: dr,
    p1: p1,
    p2: p2,
    p3: p3,
    _p1: ptyp(p1),
    _p2: ptyp(p2),
    _p3: ptyp(p3),
  )
}


#let R2SDC_Unit(x, y, stagedat) = {
  let h
  let dr = {
    import cetz.draw: *
    import "../circucetz/lib.typ": *
    let s1 = R2SDC_Stage(
      x,
      y,
      1,
      mmcell-values: stagedat.a.mmc,
      mmcell2-values: stagedat.a.mmc2,
      mux2-out: stagedat.a.mux2-out,
      tw-out: stagedat.a.tw-out,
      muxsw: stagedat.a.muxsw,
    )
    s1.draw
    content((s1._p2.x - .3, s1._p2.y), stagedat.in-txt, anchor: "east")


    let s2 = R2SDC_Stage(
      s1._p3.x + .5,
      s1._p1.y,
      0,
      mmcell-values: stagedat.b.mmc,
      mux2-out: stagedat.b.mux2-out,
      tw-out: stagedat.b.tw-out,
      muxsw: stagedat.b.muxsw,
    )
    s2.draw

    wire(s1.p3, s2.p2)
    content((s2._p3.x + .1, s2._p3.y), stagedat.out-txt, anchor: "west")
    h = s2._p3.y - s2._p1.y + 2
  }
  return (
    draw: dr,
    h: h,
  )
}
#let schm-r2sdc-3 = {
  cetz.canvas({
    import cetz.draw: *
    scale(y: -1)

    let x = 0
    let y = 0
    let stagedat = (
      (
        in-txt: $#d #h(2pt) #c #h(2pt) #b #h(2pt) #a$,
        out-txt: $$,
        a: (
          mmc: ($$, $$),
          mmc2: ($$, $$),
          mux2-out: $#a$,
          tw-out: $$,
          muxsw: true,
        ),
        b: (
          mmc: (),
          mux2-out: $$,
          tw-out: $$,
          muxsw: true,
        ),
      ),
      (
        in-txt: $#d #h(2pt) #c #h(2pt) #b$,
        out-txt: $$,
        a: (
          mmc: ($#a$, $$),
          mmc2: ($$, $#a$),
          mux2-out: $#b$,
          tw-out: $$,
          muxsw: true,
        ),
        b: (
          mmc: (),
          mux2-out: $$,
          tw-out: $$,
          muxsw: true,
        ),
      ),
      (
        in-txt: $#d #h(2pt) #c$,
        out-txt: $$,
        a: (
          mmc: ($#b$, $#a$),
          mmc2: ($$,),
          mux2-out: $#a - #c$,
          tw-out: $#a + #c$,
          muxsw: false,
        ),
        b: (
          mmc: (),
          mux2-out: $$,
          tw-out: $$,
          muxsw: true,
        ),
      ),
      (
        in-txt: $#d$,
        out-txt: $$,
        a: (
          mmc: ($#a - #c$, $#b$),
          mmc2: ($#a + #c$,),
          tw-out: $#b + #d$,
          muxsw: false,
          mux2-out: $#b - #d$,
        ),
        b: (
          mmc: (),
          mux2-out: $#a + #c$,
          tw-out: $$,
          muxsw: true,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a + #c) + (#b + #d)$,
        a: (
          mux2-out: $$,
          mmc: ($#b - #d$, $#a - #c$),
          tw-out: $(#a - #c)1$,
          muxsw: false,
          mmc2: ($#b + #d$,),
        ),
        b: (
          mmc: ($#a + #c$,),
          mux2-out: $(#a + #c) - (#b + #d)$,
          tw-out: $$,
          muxsw: false,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a + #c) - (#b + #d)$,
        a: (
          mux2-out: $$,
          mmc: ($$, $#b - #d$),
          tw-out: $(#b - #d)j$,
          muxsw: false,
          mmc2: ($#a - #c$,),
        ),
        b: (
          mmc: ($#a#c \- #b#d$,),
          mux2-out: $#a - #c$,
          tw-out: $$,
          muxsw: false,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a - #c) + (#b - #d)j$,
        a: (
          mux2-out: $$,
          mmc: ($$, $$),
          tw-out: $$,
          muxsw: false,
          mmc2: ($(#b - #d)j$,),
        ),
        b: (
          mmc: ($#a - #c$,),
          mux2-out: $(#a - #c)- (#b - #d)j$,
          tw-out: $$,
          muxsw: false,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a - #c)- (#b - #d)j$,
        a: (
          mux2-out: $$,
          mmc: ($$, $$),
          tw-out: $$,
          muxsw: false,
          mmc2: ($$,),
        ),
        b: (
          mmc: ($#a#c\-#b#d$,),
          mux2-out: $$,
          tw-out: $$,
          muxsw: false,
        ),
      ),
    )
    for i in range(stagedat.len()) {
      let u = R2SDC_Unit(x, y, stagedat.at(i))
      u.draw
      y += u.h
    }
  })
}
