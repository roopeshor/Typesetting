#import "@preview/circuiteria:0.2.0": circuit, element, util, wire
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "../drawing.typ": *
#import "@preview/cetz:0.5.2"
#import "r2mdc_4.typ": stage-2-color, stage-1-color

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
#let ckt-r2mdc = [#circuit(length: 2em, {
  element.block(
    x: 1,
    y: 0,
    w: 5,
    h: 5,
    id: "ctrl",
    name: [Controller],
		name-anchor: "north",
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
  element.block(
    x: 8,
    y: 0,
    w: 5.5,
    h: 5,
    id: "r2mdc1",
    name: [R2MDC \ Stage 0],
    ports: _r2mdcports,
		fill: stage-1-color.transparentize(80%)
  )
  element.block(
    x: 15,
    y: 0,
    w: 5.5,
    h: 5,
    id: "r2mdc2",
    name: [R2MDC \ Stage 1],
    ports: _r2mdcports,
		fill: stage-2-color.transparentize(80%)
  )

  element.block(
    x: -1,
    y: -1.3,
    w: 1,
    h: 1,
    id: "clkb",
    name: [clk],
    ports: (
      east: (
        (id: "p"),
      ),
    ),
  )

  element.block(
    x: -1,
    y: -2.3,
    w: 1,
    h: 1,
    id: "rstb",
    name: [rst],
    ports: (
      east: (
        (id: "p"),
      ),
    ),
  )
  wire.stub("ctrl-port-din", "west", name: [*din*], length: .5)
  wire.stub("ctrl-port-in_valid", "west", name: [*in_valid*], length: .5)
  wire.stub("r2mdc2-port-out1", "east", name: [*Out 1*], length: .5)
  wire.stub("r2mdc2-port-out0", "east", name: [*Out 0*], length: .5)
  wire.stub("r2mdc2-port-out_valid", "east", name: [*out valid*], length: .5)
	let dwire(x,y,dy:-1) = wire.wire("w10", (x,y), directed: true, style: "dodge", dodge-y: dy, dodge-margins: (0,0))

	dwire("clkb-port-p", "ctrl-port-clk")
	dwire("clkb-port-p", "r2mdc1-port-clk")
	dwire("clkb-port-p", "r2mdc2-port-clk")
	
	dwire("rstb-port-p", "ctrl-port-rst", dy: -2)
	dwire("rstb-port-p", "r2mdc1-port-rst", dy: -2)
	dwire("rstb-port-p", "r2mdc2-port-rst", dy: -2)
  
	vwire("w1", "ctrl-port-out_valid", "r2mdc1-port-in_valid")
  vwire("w1", "ctrl-port-out1", "r2mdc1-port-in1")
  vwire("w1", "ctrl-port-out0", "r2mdc1-port-in0")
  vwire("w1", "ctrl-port-out_cnt", "r2mdc1-port-in_cnt")
  vwire("w1", "r2mdc1-port-out_valid", "r2mdc2-port-in_valid")
  vwire("w1", "r2mdc1-port-out1", "r2mdc2-port-in1")
  vwire("w1", "r2mdc1-port-out0", "r2mdc2-port-in0")
  vwire("w1", "r2mdc1-port-out_cnt", "r2mdc2-port-in_cnt")
})]