#import "@preview/circuiteria:0.2.0": circuit, element, util, wire
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "../drawing.typ": *
#let ckt-radix2-dit-fft = [#circuit(length: 2em, {
  element.block(
    x: 10, y: 1, w: 3, h: 2.2,
    id: "bitr",
		name: "Bit reverse",
    ports: (
      north: ((id: "src", name: `src`),),
			east: ((id: "PC"),),
      south: ((id: "dest", name: `dest`),)
    )
  )
  
	element.block(
    x: 0, y: 1, w: 8.5, h: 2.5,
    id: "addr",
		name: "Address Generator",
    ports: (
      north: (
        (id: "stage", name: `stage`),
        (id: "bf_idx", name: `bf_idx`),
      ),
      south: (
        (id: "emp"),
        (id: "twiddle_idx", name: `twiddle_idx`),
        (id: "emp"),
        (id: "emp"),
        (id: "addr_a", name: `addr_a`),
        (id: "emp"),
        (id: "addr_b", name: `addr_b`),
      )
    )
  )
	
	element.block(
    x: 0, y: -5.8, w: 5, h: 2.5,
    id: "tw",
		name: "Twiddle Factor",
    ports: (
      north: ((id: "twiddle_idx", name: `twiddle_idx`),),
      east: ((id: "W", name: `W`),)
    )
  )
	element.block(
    x: 6, y: -6, w: 4, h: 3,
    id: "bf",
		name: "Butterfly",
    ports: (
      east: (
        (id: "A", name: `A`),
        (id: "B", name: `B`),
        (id: "emp"),
        (id: "C", name: `C`),
        (id: "D", name: `D`),
      ),
      west: ((id: "W", name: `W`),))
  )

	element.group(
		name: "counter",
		stroke: (dash: "dashed"),
		name-anchor: "north",
		{
			element.block(
			id: "lc",
			name: "load counter",
			x: 8, y: 5, w: 4, h: 1,
			ports: (
				south: (
					(id: "io"),
				)
			)
		)
		element.block(
			id: "bf_idxc",
			name: "bf idx",
			x: 5, y: 5, w: 3, h: 1,
			ports: (
				south: (
					(id: "io"),
				)
			)
		)
		element.block(
			id: "stage",
			name: "stage",
			x: 3, y: 5, w: 2, h: 1,
			ports: (
				south: (
					(id: "io"),
				)
			)
		)
		}
	)

	element.block(
		id: "mem",
		name: [#rotate(90deg)[mem]],
		x: 13, y: -9, w: 5, h: 9,
		ports: (
			north: (
				(id: "l_addr", name: `l_addr`),
			),
			west: (
				(id: "b_addr", name: `b_addr`),
				(id: "a_addr", name: `a_addr`),
				(id: "a_data", name: `a_data`),
				(id: "b_data", name: `b_data`),
				(id: "emp"),
				(id: "emp"),
				(id: "c_data", name:`c_data`),
				(id: "d_data", name:`d_data`),
			),
			east: (
				(id: "r_addr", name: `r_addr`),
				(id: "emp"),
				(id: "emp"),
				(id: "emp"),
				(id: "r_data", name: `r_data`),
			),
			south: (
				(id: "l_data", name: `l_data`),
			)
		)
	)
	element.block(
		id: "FSM",
		name: "FSM",
		x: 3, y:-9, w:6, h:1.5,
		ports: (
			west: (
				(id: "output_ready",),
			),
			south: (
				(id: "rst",),
				(id: "clk",),
				(id: "start",),
				(id: "input_valid",),
			)
		),
	)

	let iy = -12
	element.block(
		id: "ora", name: [#rotate(-90deg)[output_read_addr]], x: 19, y:-4, w:1, h:5,
		fill: rgb(240, 240, 240),
		ports: (
			west: ((id: "io",),),
		),
	)
	element.block(
		id: "od", name: [#rotate(-90deg)[dout]], x: 19, y:-8.5, w:1, h:2,
		fill: rgb(240, 240, 240),
		ports: (
			west: ((id: "io",),),
		),
	)

	element.block(
		id: "din", name: "din", x: 15, y:iy, w:1, h:1,
		fill: rgb(240, 240, 240),
		ports: (
			north: ((id: "io",),),
		),
	)

	element.block(
		id: "input_valid", name: "input_valid", x: 6.6, y:iy, w:3, h:1,
		fill: rgb(240, 240, 240),
		ports: (
			north: ((id: "io",),),
		),
	)
	element.block(
		id: "start", name: "start", x: 4.5, y:iy, w:1.7, h:1,
		fill: rgb(240, 240, 240),
		ports: (
			north: ((id: "io",),),
		),
	)


	element.block(
		id: "clk", name: "clk", x: 3, y:iy, w:1, h:1,
		fill: rgb(240, 240, 240),
		ports: (
			north: ((id: "io",),),
		),
	)
	element.block(
		id: "rst", name: "rst", x: 1.5, y:iy, w:1, h:1,
		fill: rgb(240, 240, 240),
		ports: (
			north: ((id: "io",),),
		),
	)
	element.block(
		id: "or", name: [#rotate(90deg)[output_ready]], x: 0, y:-10, h:3.5, w:1,
		fill: rgb(240, 240, 240),
		ports: (
			east: ((id: "io",),),
		),
	)


	hwire("w1", "addr-port-twiddle_idx", "tw-port-twiddle_idx")
  hwire("w2", "tw-port-W", "bf-port-W")
	hwire("w3", "bf_idxc-port-io", "addr-port-bf_idx")
	hwire("w4", "stage-port-io", "addr-port-stage")
	vwire("w5", "mem-port-a_data", "bf-port-A", r:50%)
	vwire("w6", "mem-port-b_data", "bf-port-B", r:45%)
	vwire("w7", "mem-port-c_data", "bf-port-C", r:25%)
	vwire("w8", "mem-port-d_data", "bf-port-D", r:40%)
	wire.wire("w9", ("addr-port-addr_a", "mem-port-a_addr"), directed: true, style: "dodge", dodge-y: -2, dodge-margins: (0,0))
	wire.wire("w10", ("addr-port-addr_b", "mem-port-b_addr"), directed: true, style: "dodge", dodge-y: -1, dodge-margins: (0,0))
	hwire("w11", "lc-port-io", "bitr-port-src")
	hwire("w12", "bitr-port-dest", "mem-port-l_addr")
	hwire("w13", "din-port-io", "mem-port-l_data")
	hwire("w14", "ora-port-io", "mem-port-r_addr")
	hwire("w15", "mem-port-r_data", "od-port-io")
	hwire("w15", "FSM-port-output_ready", "or-port-io")
	hwire("w15", "rst-port-io", "FSM-port-rst", r:60%)
	hwire("w15", "clk-port-io", "FSM-port-clk", r:40%)
	hwire("w15", "start-port-io", "FSM-port-start", r:20%)
	hwire("w15", "input_valid-port-io", "FSM-port-input_valid")
})]

#let ckt-radix2-dit-fft-fsm = [ #diagram(
    node-stroke: .7pt,
    node(`IDLE`),
    edge(label: " input is valid", "-|>"),
    node(
      (3, 0),
      `LOAD:
Load result to mem`,
    ),
    edge(label: "All inputs filled", "-|>", label-side: left),
    node(
      (3, 1.5),
      `COMPUTE:
Load computes to mem`,
    ),
    edge(label: "Counter exhausted", "-|>", label-side: left),
    node(
      (0, 1.5),
      `DONE:
set output_ready`,
    ),
    edge((0, 1.5), (0, 0), "-|>"),
  )]