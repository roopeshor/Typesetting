#import "@preview/circuiteria:0.2.0": circuit, element, util, wire
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "../drawing.typ": *
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
#let ckt-r2sdc = [#circuit(length: 2em, {
  element.block(
    x: 1,
    y: 0,
    w: 5,
    h: 4,
    id: "ctrl",
    name: [Controller],
    name-anchor: "north",
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
  element.block(
    x: 8,
    y: 0,
    w: 5.5,
    h: 4,
    id: "r2sdc1",
    name: [R2SDC Stage 1],
    ports: _r2sdcports,
    name-anchor: "north",
    fill: stage-1-color.transparentize(80%),
  )
  element.block(
    x: 15,
    y: 0,
    w: 5.5,
    h: 4,
    id: "r2sdc2",
    name: [R2SDC Stage 0],
    ports: _r2sdcports,
    name-anchor: "north",
    fill: stage-2-color.transparentize(80%),
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
  wire.stub("r2sdc2-port-dout", "east", name: [*dout*], length: .5)
  wire.stub("r2sdc2-port-out_valid", "east", name: [*out valid*], length: .5)
  let dwire(x, y, dy: -1) = wire.wire("w10", (x, y), directed: true, style: "dodge", dodge-y: dy, dodge-margins: (0, 0))

  dwire("clkb-port-p", "ctrl-port-clk")
  dwire("clkb-port-p", "r2sdc1-port-clk")
  dwire("clkb-port-p", "r2sdc2-port-clk")

  dwire("rstb-port-p", "ctrl-port-rst", dy: -2)
  dwire("rstb-port-p", "r2sdc1-port-rst", dy: -2)
  dwire("rstb-port-p", "r2sdc2-port-rst", dy: -2)

  vwire("w1", "ctrl-port-out_valid", "r2sdc1-port-in_valid")
  vwire("w1", "ctrl-port-dout", "r2sdc1-port-din")
  vwire("w1", "r2sdc1-port-out_valid", "r2sdc2-port-in_valid")
  vwire("w1", "r2sdc1-port-dout", "r2sdc2-port-din")
})]