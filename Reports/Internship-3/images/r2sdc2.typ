#import "@preview/cetz:0.5.2"
#import "colors.typ": *
#import "shapes.typ": *

#let ckt-r2sdc-stage = {
  cetz.canvas({
    import cetz.draw: *
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
      cnt._p2.x + 3,
      cnt._p2.y,
      text(size: 9pt)[`Twiddle`],
      w: 1.5,
      h: 1.5,
      mpy: 0.3,
      ports: (
        left: (
          (id: "state", name: `state`),
          (id: "k", name: `k`),
        ),
        right: (
          (id: "W", name: `W`),
        ),
      ),
    )

    tw.draw
    zigzagv(cnt.p2, tw.ports.k, ratio: 0)
    zigzagv(cnt.p2, tw.ports.state, ratio: 0)
    content((cnt._p2.x, tw.ports._state.y), `state`, anchor: "south-west", padding: .1)


    //// DF, Muxers, Shiftr reg
    x = cnt._p2.x
    y = cnt._p1.y - 3
    let bf = bf_skel(x, y, v-space: 1.2, h-space: 1.5)
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
    zigzagv(data_shr.p1, bf.p1, ratio: -2)

    let mux1 = mux(..bf.p3, inps: (`1`, `0`), inp-pos-reverse: true)
    mux1.draw
    let mux2 = mux(..bf.p4, inps: (`0`, `1`))
    mux2.draw


    let din = wedge(inpx, bf._p2.y, txt: `din`)
    din.draw
    wire(din.p2, bf.p2)

    let wcm = zigzagv_get_corner(
      (cnt._p2.x + 1, cnt._p2.y - .15),
      mux2.sw1,
      ratio: 1,
    )
    wcm.draw
    line(mux1.sw1, mux2.sw2)
    let w1 = zigzagv_get_corner(bf.p1, (bf._p3.x, mux1.inp_pos.at(1)), ratio: -.1)
    w1.draw
    joint(wcm.c1)
    zigzagv(mux2.out, data_shr.p2, ratio: -3)


    ///// input validators
    let valid_sr = memcell(8, cnt._p1.x, cnt._p1.y + 2.2, name: `valid_sr`, name-anchor: "north")

    valid_sr.draw
    let in_valid = wedge(inpx, valid_sr._p1.y, txt: `in_valid`)
    in_valid.draw
    line(in_valid.p1, valid_sr.p1)

    let or1 = or-gate(valid_sr._p2.x + 1, valid_sr._p2.y - .7, w: .7, h: .3)
    or1.draw
    let w1 = zigzagv_get_corner(in_valid.p2, or1.p1, ratio: .1)
    w1.draw
    joint(w1.c1)
    w1 = zigzagv_get_corner(valid_sr.p2, or1.p2)
    w1.draw
    joint(w1.c1)

    let ppl = pipelined_multiplier(
      mux1._out.x + 3,
      mux1._out.y,
    )
    ppl.draw
    wire(mux1.out, ppl.p1)
    zigzagv(tw.ports.W, ppl.p2, ratio: 1)

    //// last stage
    let pre_stage_en = Dff(ppl._clk.x, or1._p3.y, name: `pre_stage_en`)
    pre_stage_en.draw
    wire(or1.p3, pre_stage_en.p1)
    content(or1.p3, `stage_en`, anchor: "south-west", padding: .1)
    let dout_ff = Dff_en(ppl._out.x + 1, ppl._out.y, `dout_ff`)
    wire(ppl.out, dout_ff.p1)
    dout_ff.draw
    zigzagv(pre_stage_en.p2, dout_ff.en, ratio: 1)

    let and1 = and-gate(or1._p3.x + 2, or1._p3.y + 1)
    and1.draw

    let w3 = zigzagv_get_corner(or1.p3, and1.p1, ratio: .8)
    w3.draw
    joint(w3.c1)

    zigzagv_corner(valid_sr.p2, and1.p2, w1.c1)

    let mul_valid_ff = Dff(dout_ff._p1.x, and1._p3.y, name: `mul_valid`)

    mul_valid_ff.draw
    wire(and1.p3, mul_valid_ff.p1)

    let dout = wedge(dout_ff._p2.x + 2, dout_ff._p2.y, txt: `dout`, txtpos: "west", padx: .3)
    dout.draw
    let out_valid = wedge(dout._p1.x, mul_valid_ff._p2.y, txt: `out_valid`, txtpos: "west", padx: .3)
    out_valid.draw

    wire(dout_ff.p2, dout.p1)
    wire(mul_valid_ff.p2, out_valid.p1)
    blockx2 = out_valid._p1.x
    blocky2 = out_valid._p1.y + 1

    rect(
      (blockx1, blocky1),
      (blockx2, blocky2),
    )
  })
}


#let R2SDC_Stage(x, y, stage, mmcell-values: (), mmcwidth: 1, mmc2width: 1.4, mux2-out: "", tw-out: "", mmcell2-values: ()) = {
  let p1
  let p2
  let p3
  let dr = {
    import cetz.draw: *

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
    let bf = bf_skel(shr._p2.x + .2, shr._p2.y, v-space: .6, h-space: .7)
    bf.draw


    let wlsr-xmin = calc.min(shr._p1.x - .2, bf._p1.x - .2)
    p1 = (wlsr-xmin, bf._p1.y)
    line(shr.p2, bf.p1)
    p2 = (shr._p1.x - .2, bf._p2.y)
    line(bf.p2, p2)
    joint(bf.p1)

    let mux1 = mux(..bf.p3, inps: (`1`, `0`), inp-pos-reverse: true, h-size: .8, y-offset: .25)
    mux1.draw
    let mux2 = mux(..bf.p4, inps: (`0`, `1`), h-size: .8, y-offset: .25)
    mux2.draw
    let shr-r-p1 = (mux1._out.x - .1, shr._p2.y - .7)

    zigzagv(shr-r-p1, mux2.out, ratio: 5)
    zigzagv(shr.p1, shr-r-p1, ratio: -.1)


    /// mux2-out
    content((shr._p1.x + .7, shr._p2.y - .7), mux2-out, anchor: "south-west", padding: .1)

    x = mux2._out.x + 1
    y = (mux1._out.y + mux2._out.y) / 2

    let tw = Label((x, y), $W_(#N)$)
    tw.draw

    if (N > 1) {
      p3 = (tw._p4.x + 1.3, p2.at(1))
    } else {
      p3 = (tw._p4.x + .5, p2.at(1))
    }
    zigzagv(mux1.out, tw.p2, ratio: 1)
    zigzagv(tw.p4, p3, ratio: 0)

    content((tw._p4.x - .3, p3.at(1) + .1), tw-out, anchor: "north-west", padding: .1)

    zigzagv(bf.p1, (mux1.x, mux1.inp_pos.at(1)), ratio: 0)
    zigzagv(bf.p2, (mux2.x, mux2.inp_pos.at(1)), ratio: 0)

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
    let s1 = R2SDC_Stage(
      x,
      y,
      1,
      mmcell-values: stagedat.a.mmc,
      mmcell2-values: stagedat.a.mmc2,
      mux2-out: stagedat.a.mux2-out,
      tw-out: stagedat.a.tw-out,
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
        in-txt: $#d #h(2pt) #c #h(2pt) #b #h(10pt) #a$,
        out-txt: $$,
        a: (
          mmc: ($$, $$),
          mmc2: ($$, $$),
          mux2-out: $#a$,
          tw-out: $$,
        ),
        b: (
          mmc: (),
          mux2-out: $$,
          tw-out: $$,
        ),
      ),
      (
        in-txt: $#d #h(2pt) #c #h(10pt) #b$,
        out-txt: $$,
        a: (
          mmc: ($$, $#a$),
          mmc2: ($$, $#a$),
          mux2-out: $#b$,
          tw-out: $$,
        ),
        b: (
          mmc: (),
          mux2-out: $$,
          tw-out: $$,
        ),
      ),
      (
        in-txt: $#d #h(10pt) #c$,
        out-txt: $$,
        a: (
          mmc: ($#a$, $#b$),
          mmc2: ($$,),
          mux2-out: $#a - #c$,
          tw-out: $#a + #c$,
        ),
        b: (
          mmc: (),
          mux2-out: $$,
          tw-out: $$,
        ),
      ),
      (
        in-txt: $#d$,
        out-txt: $$,
        a: (
          mmc: ($#a - #c$, $#b$),
          mmc2: ($#a + #c$,),
          tw-out: $#b + #d$,
          mux2-out: $#b - #d$,
        ),
        b: (
          mmc: (),
          mux2-out: $#a + #c$,
          tw-out: $$,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a + #c) + (#b + #d)$,
        a: (
          mux2-out: $$,
          mmc: ($#b - #d$, $#a - #c$),
          tw-out: $#a - #c$,
          mmc2: ($#b + #d$,),
        ),
        b: (
          mmc: ($#a + #c$,),
          mux2-out: $(#a + #c) - (#b + #d)$,
          tw-out: $$,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a + #c) - (#b + #d)$,
        a: (
          mux2-out: $$,
          mmc: ($$, $#b - #d$, ),
          tw-out: $(#b - #d)j$,
          mmc2: ($#a - #c$,),
        ),
        b: (
          mmc: ($#a#c \- #b#d$,),
          mux2-out: $#a - #c$,
          tw-out: $$,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a - #c) + (#b - #d)j$,
        a: (
          mux2-out: $$,
          mmc: ($$, $$),
          tw-out: $$,
          mmc2: ($(#b - #d)j$,),
        ),
        b: (
          mmc: ($#a - #c$,),
          mux2-out: $(#a - #c)- (#b - #d)j$,
          tw-out: $$,
        ),
      ),
      (
        in-txt: $$,
        out-txt: $(#a - #c)- (#b - #d)j$,
        a: (
          mux2-out: $$,
          mmc: ($$, $$),
          tw-out: $$,
          mmc2: ($$,),
        ),
        b: (
          mmc: ($#a#c\-#b#d$,),
          mux2-out: $$,
          tw-out: $$,
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
