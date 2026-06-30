#import "@preview/cetz:0.5.2"
#import "r2mdc_4.typ": stage-1-color, stage-2-color

#let _r2mdcports = (
  west: (
    (id: "in_valid", name: `in_valid`),
    (id: "in0", name: `in0`),
    (id: "in1", name: `in1`),
    (id: "in_cnt", name: `in_cnt`),
  ),
  east: (
    (id: "out_valid", name: `out_valid`),
    (id: "out0", name: `out0`),
    (id: "out1", name: `out1`),
    (id: "out_cnt", name: `out_cnt`),
  ),
  south: (
    (id: "clk", name: `clk`, clocked: true),
    (id: "rst", name: `rst`),
  ),
)
#let ckt-r2mdc = cetz.canvas({
  import "../circucetz/lib.typ": *
  let block-h = 4.3
  let ctrl = block(
    1,
    0,
    w: 5,
    h: block-h,
    name: align(center)[#text(font: "Source Sans 3")[*Controller*]],
    fill: maroon.transparentize(80%),
    ports: (
      west: (
        (id: "din", name: `din`),
        (id: "in_valid", name: `in_valid`),
      ),
      east: (
        (id: "out_valid", name: `out_valid`),
        (id: "out0", name: `out0`),
        (id: "out1", name: `out1`),
        (id: "out_cnt", name: `out_cnt`),
      ),
      south: (
        (id: "clk", name: `clk`),
        (id: "rst", name: `rst`),
      ),
    ),
  )
  let S0 = block(
    8,
    0,
    w: 5.5,
    h: block-h,
    name: align(center)[#text(font: "Source Sans 3")[*R2MDC \ Stage 0*]],
    ports: _r2mdcports,
    fill: stage-1-color.transparentize(80%),
  )
  let S1 = block(
    15,
    0,
    w: 5.5,
    h: block-h,
    name: align(center)[#text(font: "Source Sans 3")[*R2MDC \ Stage 1*]],
    ports: _r2mdcports,
    fill: stage-2-color.transparentize(80%),
  )

  let clk = io-pin(0, -1.3, name: `clk`)
  let rst = io-pin(0, -2.3, name: `rst`)
  let din = io-pin(0, ctrl.ports._din.y, name: `din`)
  let in_valid = io-pin(0, ctrl.ports._in_valid.y, name: `in_valid`)

  ctrl.draw
  S0.draw
  S1.draw

  clk.draw
  rst.draw
  din.draw
  in_valid.draw

  wire(din.p1, ctrl.ports.din)
  wire(in_valid.p1, ctrl.ports.in_valid)

  wire(ctrl.ports.out_valid, S0.ports.in_valid)
  wire(ctrl.ports.out0, S0.ports.in0)
  wire(ctrl.ports.out1, S0.ports.in1)
  wire(ctrl.ports.out_cnt, S0.ports.in_cnt)

  wire(S0.ports.out_valid, S1.ports.in_valid)
  wire(S0.ports.out0, S1.ports.in0)
  wire(S0.ports.out1, S1.ports.in1)
  wire(S0.ports.out_cnt, S1.ports.in_cnt)

  let lwires = (
    L-wire(clk.p2, ctrl.ports.clk),
    L-wire(clk.p2, S0.ports.clk),
    L-wire(rst.p2, S0.ports.rst),
    L-wire(rst.p2, ctrl.ports.rst),
  )
  for wi in lwires {
    wi.draw
    joint(wi.c1).draw
  }

  L-wire(clk.p2, S1.ports.clk).draw
  L-wire(rst.p2, S1.ports.rst).draw
})
