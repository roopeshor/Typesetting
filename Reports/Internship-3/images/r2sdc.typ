#import "@preview/cetz:0.5.2"
#import "colors.typ": *

#let _r2sdcports = (
  west: (
    (id: "s"),
    (id: "din", name: `din`),
    (id: "in_valid", name: `in_valid`),
    (id: "s"),
  ),
  east: (
    (id: "s"),
    (id: "dout", name: `dout`),
    (id: "out_valid", name: `out_valid`),
    (id: "s"),
  ),
  south: (
    (id: "clk", name: `clk`, clocked: true),
    (id: "rst", name: `rst`),
  ),
)
#let ckt-r2sdc = cetz.canvas({
  import "../circucetz/lib.typ": *
  let block-h = 3
  let ctrl = block(
    1,
    0,
    w: 5,
    h: block-h,
    name: "Controller",
    name-anchor: "north",
    name-padding: .3,
    fill: maroon.transparentize(80%),
    ports: (
      west: (
        (id: "s"),
        (id: "din", name: `din`),
        (id: "in_valid", name: `in_valid`),
        (id: "s"),
      ),
      east: (
        (id: "s"),
        (id: "dout", name: `dout`),
        (id: "out_valid", name: `out_valid`),
        (id: "s"),
      ),
      south: (
        (id: "clk", name: `clk`),
        (id: "rst", name: `rst`),
      ),
    ),
  )
  let S1 = block(
    8,
    0,
    w: 5.5,
    h: block-h,
    name: "R2SDC Stage 1",
    ports: _r2sdcports,
    name-anchor: "north",
    name-padding: .3,
    fill: stage-1-color.transparentize(80%),
  )
  let S0 = block(
    15,
    0,
    w: 5.5,
    h: block-h,
    name: "R2SDC Stage 0",
    ports: _r2sdcports,
    name-anchor: "north",
    name-padding: .3,
    fill: stage-2-color.transparentize(80%),
  )

  ctrl.draw
  S1.draw
  S0.draw

  let din = io-pin(0, ctrl.ports._din.y, name: `din`)
  let in_valid = io-pin(0, ctrl.ports._in_valid.y, name: `in_valid`)
  let clk = io-pin(0, ctrl.ports._clk.y - .8, name: `clk`)
  let rst = io-pin(0, clk._p1.y - .7, name: `rst`)

  din.draw
  in_valid.draw
  clk.draw
  rst.draw

	wire(din.p2, ctrl.ports.din)
	wire(in_valid.p2, ctrl.ports.in_valid)
	
  wire(ctrl.ports.dout, S1.ports.din)
  wire(S1.ports.dout, S0.ports.din)
  wire(ctrl.ports.out_valid, S1.ports.in_valid)
  wire(S1.ports.out_valid, S0.ports.in_valid)

  let crosswires = (
    L-wire(clk.p2, ctrl.ports.clk),
    L-wire(clk.p2, S1.ports.clk),
    L-wire(rst.p2, ctrl.ports.rst),
    L-wire(rst.p2, S1.ports.rst),
  )

  for w in crosswires {
    w.draw
    joint(w.c1).draw
  }
  L-wire(clk.p2, S0.ports.clk).draw
  L-wire(rst.p2, S0.ports.rst).draw
})
