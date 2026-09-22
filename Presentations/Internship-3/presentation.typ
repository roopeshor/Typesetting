#import "@preview/touying:0.7.4": *
#import "theme.typ": *

#let pc = rgb("#264684");

#show: my-theme.with(
  aspect-ratio: "16-9",
	color-primary: pc,
  config-info(
    title: [Internship Presentation],
    subtitle: [Analysis and Implementation of FFT Algorithms],
    subtitle2: [Advanced Systems Laboratory\
      Defence Research And Development Organisation],
    subtitle3: [G. Venkat Reddy, Sc 'F'],
    subtitle4: [May 18 2026 - June 15 2026],
    author: text(weight: "bold")[Roopesh O R],
    date: datetime.today(),
  ),
)
#show link: set text(fill: pc)
#show raw: it => {
  if it.lang == none {
    text(size: 1.4em)[#raw(lang: "tcl", it.text)]
  } else {
    it
  }
}
// #show raw: set text(size: 14pt)
#let code-preview(cnt-string, strk: 1pt, rg: 0pt, display-indicator: false, columns: 2) = {
  let inputs = if type(cnt-string) == array { cnt-string } else { (cnt-string,) }
  let cells = ()
  if display-indicator {
    cells = (
      [*Typst code*],
      [*Output*],
    )
  }
  for val in inputs {
    let clean-val = val.trim()
    cells.push([
      #raw(clean-val, lang: "typst")
    ])
    cells.push([
      #set text(size: .8em)
      #eval(clean-val, mode: "markup")
    ])
  }

  table(
    columns: columns,
    stroke: strk,
    row-gutter: rg,
    align: (left, top),
    ..cells
  )
}

#title-slide()
#set document(title: "Internship presentation")
== Outline <touying:hidden>
#components.adaptive-columns(
  outline(title: none, indent: 1em),
)

= About The Organisation: DRDO <touying:skip>
#grid(
  columns: (2fr, 1fr),
  [
    - Premier agency under the Ministry of Defence, estd:  1958
    - Responsible for the research and development of defence technologies.
    - Has network of over 50 laboratories, specializing in various disciplines such as aeronautics, armaments, electronics, missiles, combat vehicles, naval systems, advanced computing, simulation, and life sciences.
    - *Advanced System Laboratory (ASL)*: engaged in the development of solid propulsion technologies, composites, aerospace mechanisms, etc
  ],
  align(center + horizon)[
    #image("images/drdo.svg", height: 50%)
  ],
)

= Overview of internship <touying:skip>
- Fourier Transform is computationally expensive
- Internship involved understanding, analyzing and implementing few FFT algorithms using SystemVerilog in the context of FPGA
- Implemented Radix-2 Inplace, R2MDC, R2SDC and Winograd
- For resource analysis Artix-7 (xc7a100tcsg324-1) family of FPGA was targeted
- Specs:
  - 15,850 CLB slices (4x6-input LUT, 8 FF)
  - 4860 Kb dual-port block RAM
  - 240 DSP slices with 25 x 18 multiplier, 48-bit accumulator
  - 101,440 Logic cells
  - 13 Mb Block RAM
  - 300 User I/O

= Techniques
== Introduction
- Implemented Radix-2 Inplace, R2MDC, R2SDC and 5 point Winograd
- Transform size is parameterized in Radix-2 Inplace, R2MDC, R2SDC
- Winograd is not scalable: needs different implementation for different transform sizes

== Method used in analysis
- Simulation and debugging was done using Verilator
- Synthesis and implementation in Vivado
- For automating report generation in Vivado, `tcl` script was used
- Assumptions:
  - 10ns clock
  - control signal toggle rate: 2%
  - toggle rate & static probability for I/O: 50%
- Throughput :
$
  "Number of samples"/("Number of cycles to process whole input") times "max frequency of operation"
$

== Cooley-Tukey: Radix-2 DIT
#grid(
  columns: (1.2fr, 1fr),
  [
    - CT: Re-expresses the DFT of an size $N_1 N_2$ in terms of $N_1$ smaller DFTs of sizes $N_2$
    - Specific methods: Radix-2, Radix-4, mixed-radix
    - For Radix-2 overall time complexity : $cal(O)(N log N)$
  ],
  [
    #figure(
      image("images/radix2-8pt-sf.svg"),
      caption: [Signal flow graph of 8-point radix-2 DIT-FFT],
    )<fig:bf8r2>
  ],
)

#pagebreak()
=== Implementation
- Burst architecture
- I/O are fixed point complex numbers
- Output available after $N log_2(N) \/ 2$ cycles after input has been loaded
#figure(
  image("images/ckt-radix2.svg", width: 70%),
  caption: [Radix-2 In-place implementation],
)

=== Simulation result
#figure(
  image("images/radix2-dit-N=4.png"),
  caption: [Simulation result of 4 point Radix-2 DIT-FFT for a ramp input],
)<fig:output-ditr2>

== Radix-2 Multi Path Delay Commutator (R2MDC)
- Based on the Decimation in Frequency (DIF)
- Takes 1 input and produces 2 outputs per cycle
#figure(
  image("images/R2MDC_4_signalflow.svg", width: 70%),
  caption: [Signal flow graph of 4-point radix-2 DIF-FFT],
)
#figure(
  image("images/R2MDC_signalflow1.svg", width: 90%),
  caption: [R2MDC algorithm for 4 point case],
)
#figure(
  image("images/R2MDC_signalflow2.svg", width: 90%),
  caption: [R2MDC algorithm for 4 point case],
)
#pagebreak()
#align(horizon)[
	=== Implementation
  #figure(
    image("images/ckt-r2mdc.svg", width: 90%),
    caption: [Schematic of R2MDC implementation],
  )
  #figure(
    image("images/ckt-r2mdc-stage.svg", width: 90%),
    caption: [ Inside a single R2MDC Stage. All modules with wedge is clocked],
  )
]

#pagebreak()
=== Simulation result
#figure(
  image("images/r2mdc_4_sim.png", width: 80%),
  caption: [Simulation result for two 4 point test signals in R2MDC],
)
- 2 different colors $->$ different inputs.
- 2 outputs are obtained at same clock cycle
- Takes $log_2(N)$ cycles to get all ouputs after last input has inserted.

== Radix-2 Single Path Delay Commutator (R2SDC)
- Another pipelined implementation of DIF algorithm
- Produces single output per cycle
- Uses fewer number of shift registers compared to MDC (expense of higher latency and complexity)

#align(center + horizon)[
  #figure(
    image("images/schm-r2sdc-3-1.svg", height: 95%),
    caption: [Steps involved in a 4 point R2SDC algorithm],
  )

  #figure(
    image("images/schm-r2sdc-3-2.svg", height: 95%),
    caption: [Steps involved in a 4 point R2SDC algorithm],
  )

  #figure(
    image("images/schm-r2sdc-3-3.svg", width: 95%),
    caption: [Steps involved in a 4 point R2SDC algorithm],
  )]

#pagebreak()

=== Implementation
#align(horizon)[
  #figure(
    image("images/r2sdc-b.svg", width: 90%),
    caption: [Schematic of R2SDC implementation],
  )
  #figure(
    image("images/r2sdc-s.svg", width: 90%),
    caption: [ Inside a single R2SDC Stage. All modules with wedge is clocked],
  )
]
=== Simulation result
- The output arrives one clock cycle later.
- Burst achitecture
#figure(
  image("images/r2sdc_4_sim.png"),
  caption: [Simulation result for 4 point complex test signal in R2SDC],
)

== Winograd
#slide()[
  - Actually a fast convolution algorithm for reducing multiplications
  - Higher number of adders and higher routing complexity
  - Particularly used in ASIC contexts and small sized DFTs in CT algorithm
  - Implementation details vary for different lengths
  === Derivation for 5-point
  5 point DFT is given by:

  $ Y_k = sum_(n=0)^4 x_n W^(n k) $
  *Idea 1*: prime length DFT can be done as circular convolution,
]

#import "@preview/numty:0.1.0" as nt
#import "utils.typ": *
#let out-map(txt) = { $Y'(#txt)$ }
#let outr-map(txt) = { $Y(#txt)$ }
#let in-map(txt) = { $x_(#txt)$ }
#let twiddle-map(txt) = {
  map-colors(txt, $W^(#txt)$)
}
#let twiddle-map-uncolored(txt) = { text[$W^(#txt)$] }
#let row-col = range(5)
#let row-col-T = transpose_vec(row-col)

#let matc = row-col-T
#let matM = elementwise-transform-2d(matrix-from-rc(row-col, row-col, mod-arith), twiddle-map)
#let matcY = elementwise-transform-2d(row-col-T, outr-map)
#let matcx = elementwise-transform-2d(row-col-T, in-map)
#slide()[


  #set math.mat(column-gap: 1em, delim: "[")
  #grid(
    columns: (2fr, 1fr),
    [
      $
        mat(..matcY) = quad #place(top + left, dy: -4.3em, dx: 1.1em, math.mat(row-col, delim: none, column-gap: 1.7em))
        #place(dx: -.35em, dy: -2.4em, math.mat(..matc, row-gap: .33em, delim: none))
        mat(..matM)
        mat(..matcx)
      $
    ],
    [

      The first row corresponds to DC sum, and the rest of elements can be written as:
      $
        Y_(k) = x_0 + Y'(k) , quad k > 0
      $

    ],
  )
  #pause
  #v(20pt)
  #align(horizon)[
    #grid(
      columns: (2fr, 1fr),
      [
        Where $Y'(k)$ is

        #let rc = range(1, 5)
        #let rc-T = transpose_vec(rc)

        #let matM = elementwise-transform-2d(matrix-from-rc(rc, rc, mod-arith), twiddle-map)
        #let matcY = elementwise-transform-2d(rc-T, out-map)
        #let matcx = elementwise-transform-2d(rc-T, in-map)

        $ mat(..matcY) = mat(..matM)mat(..matcx) $
      ],
      [
        Matrix can be rearranged to Toeplitz form and Winograd convolution algorithm can be applied.
      ],
    )]
]
#slide()[
  #underline[*Idea 2*: Rader Mapping]
  When $N$ is a prime number, set of non-zero numbers ${1, 2, …, N-1}$ can be permuted using following scheme:
  $n = g^(-q) thick (mod N)$

  $ Y'(g^p) = sum_(q = 0)^(N - 2) x(g^(-q)) W^(g^(p-q)) $
  #pause
  Corresponding matrix form is:

  #let output-mapping = ();
  #let input-mapping = ();
  #let row = range(0, 4)
  #for i in row {
    output-mapping += (mod-arith(calc.pow(2, i), 1),)
    input-mapping += (inv-pow-mod(2, i, 5),)
  }

  #let rader-perm-mat = matrix-from-rc(input-mapping, output-mapping, mod-arith)

  #let matM = elementwise-transform-2d(rader-perm-mat, twiddle-map)
  #let matcY = elementwise-transform-2d(transpose_vec(output-mapping), out-map)
  #let matcx = elementwise-transform-2d(transpose_vec(input-mapping), in-map)

  $ mat(..matcY, delim: "[") = mat(..matM, delim: "[")mat(..matcx, delim: "[") $
]

#slide()[
  Now the operation has become a length-4 cyclic convolution of sequences
  #let tthick = $thick thick$
  #let matcx = matcx.join().join($,tthick$)
  #let matW = matM.at(0).join($,tthick$)
  $
        a_q & = x(2^(-q)) = {matcx} \
    b_(p-q) & = W^(2^(p-q)) = {W^1, tthick W^2, tthick W^4, tthick W^3} \
    Y'(2^p) & = sum_(q = 0)^3 a_q dot b_((p-q)thick (mod 4))
  $
  #pause
  Expressing this sequence as polynomials:
  $
    a
    x'(z) = x_1 + x_3 z + x_4 z^2 + x_2 z^3#h(1cm)
    W'(z) = W^1 + W^2 z + W^4 z^2 + W^3 z^3
  $

  The circular convolution is given by:
  $Y'(z) = x'(z)W'(z) thick (mod z^4-1)$.\
  The required values are coefficients of $Y'(z)$
]
#slide()[
  *Winograd algorithm:*
  + Choose a cyclotomic polynomial $m(z)$ with $deg(m) >  deg[W'x']$ and factor it into $k+1$ relatively prime polynomials with real coefficients: $ m^((0)), m^((1)), ..., m^((k))$
  + Let $M^((i)) = m \/ m^((i))$. Use Euclidean GCD algorithm to solve Bezout's identity and find $N^((i))$: $ m^((i))n^((i)) + M^((i)) N^((i)) = 1 $
  + For $i = 0, 1, ..., k$.compute:
    $ w^((i)) & = W'(z) & mod m^((i))
		#h(1.2cm) x^((i)) & = x'(z) & mod m^((i)) 
    #h(1.2cm) y^((i)) & = w^((i)) x^((i)) thick & mod m^((i)) $
		// #v(10pt)
  + Compute $Y'(z)$ using:
    $ Y'(z) = [sum_(i=0)^(k) y^((i)) N^((i)) M^((i))] thick mod m(z) $
]


#figure(
  image("images/winograd5-ckt.svg", height: 90%),
  caption: [Signal flow of modified Winograd algorithm for 5 point DFT.],
)<fig:winograd-ckt>

=== 16 Point Winograd algorithm
#figure(
  caption: [Output of 16 point Winograd implementation for 2 consecutive inputs.],
  image("images/winograd16-waveform.png"),
)

= Comparison
== Comparison of 16 point transforms
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4"
#import "@preview/numty:0.1.0" as nt
#v(-15pt)


#let Total-LUT-N = (
  (104, 100.6, 150.7, 95.4),
  (34.8, 26.1, 19.1, 12.6, 8.1, 5.1, 3.4, 2.7, 2.3, 1.9, 1.8),
  (44.75, 32.25, 21.18, 13.31, 8.37, 5.23, 3.40, 2.35, 1.77, 1.42, 1.24),
)

#let SLR-per-N = (
  (0, 0, 0, 0),
  (4.125, 4.1875, 4.1875, 3.17187, 2.38281, 1.99609, 1.67187, 1.74902, 1.76904, 1.68139, 1.68444),
  (4.125, 4.125, 3.0937, 2.0625, 1.5468, 1.2890, 1.1601, 1.0957, 1.0791, 1.0473, 1.0393),
)

#let FF-per-N = (
  (37.2, 34.6, 33.6, 32.7),
  (50.5, 40.312, 26.937, 17.046, 10.468, 6.355, 3.841, 2.165, 1.569, 1.087, 0.823),
  (30.87, 20.43, 13, 8.15, 5.16, 3.37, 2.33, 1.74, 1.41, 1.22, 1.12),
)

#let RAMB36 = (
  (0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 16),
  (0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4),
)
#let RAMB18 = (
  (0, 0, 0, 0),
  (0, 0, 0, 0, 0, 8, 10, 12, 12, 0, 16),
  (0, 0, 0, 0, 0, 2, 4, 6, 8, 8, 10),
)

#let BRAM = nt.add(RAMB36, RAMB18)

#let DSP-per-N = (
  (0.5, 0.25, 0.125, 0.0625),
  (1, 0.75, 0.5, 0.3125, 0.1875, 0.1093, 0.0625, 0.0351, 0.0195, 0.0107, 0.0058),
  (1, 0.75, 0.5, 0.3125, 0.1875, 0.1093, 0.0625, 0.0351, 0.0195, 0.0107, 0.0058),
)

#let Power = (
  (98, 104, 153, 134),
  (176, 187, 197, 209, 221, 250, 264, 293, 332, 419, 571),
  (145, 154, 163, 172, 185, 197, 211, 232, 263, 315, 393),
)

#let Fmax = (
  (81.38, 79.23, 66.41, 67.23),
  (145.53, 137.15, 136.14, 131.63, 121.28, 121.13, 118.89, 117.08, 114.37, 116.68, 118.60),
  (116.36, 118.32, 113.86, 110.50, 110.13, 107.93, 113.88, 107.44, 107.03, 107.70, 104.65),
)

#let point-sizes = (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)

#let Throughput = ()
#let N_ = nt.pow(2, point-sizes).slice(0, 4);
#let TPconsts = (
  nt.div(
    N_,
    (
      nt.add(
        N_,
        nt.mult(nt.div(N_, 2), point-sizes.slice(0, 4)),
      )
    ),
  ),
  (2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2),
  (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
)
#for i in range(Fmax.len()) {
  let t = ()
  let fm = Fmax.at(i)
  Throughput += (nt.mult(fm, TPconsts.at(i)),)
}

// #Throughput.len()
#let colors = (
  blue,
  red,
  green,
)

// dont change
#let algos = (
  "In-place",
  "R2MDC",
  "R2SDC",
)

#let plots-to-do = (
  "Total LUTs/N": Total-LUT-N,
  // "SLR*/N": SLR-per-N,
  "Flip-Flops/N": FF-per-N,
  // "RAMB36": RAMB36,
  // "RAMB18": RAMB18,
  "DSPs/N": DSP-per-N,
  "BRAM": BRAM,
  "Power": Power,
  "Fmax": Fmax,
  "Throughput": Throughput,
)
#let y-units = (
  "Total LUTs/N": "units/Sa",
  "SLR*/N": "units/Sa",
  "Flip-Flops/N": "units/Sa",
  "RAMB36": "units",
  "RAMB18": "units",
  "BRAM": "units",
  "DSPs/N": "units/Sa",
  "Power": "mW",
  "Fmax": "MHz",
  "Throughput": "MSa/s",
)

#let plot-graph(plots, i) = {
  let p = plots.flatten().sorted()

  cetz.canvas({
    import cetz.draw: *
    import cetz-plot: *
    content((3, 4.4), text()[#i])
    plot.plot(
      size: (6, 4.1),
      axis-style: "scientific",
      x-label: "",
      y-label: y-units.at(i),
      y-axis: (
        ticks: (step: 2), // Ticks will appear every 2 units instead of the default
      ),
      {
        let dat = ()
        for j in range(plots.len()) {
          let algodata = plots.at(j)
          plot.add(
            point-sizes.zip(algodata),
            style: (stroke: colors.at(j)),
          )
          plot.add-vline(
            ..point-sizes,
            style: (stroke: (paint: gray, thickness: .5pt, dash: "dotted")),
          )
        }
      },
    )
  })
}

#let grd = (
  ..plots-to-do.keys().map(i => plot-graph(plots-to-do.at(i), i)),
  align(horizon + center)[
    #text(size: 11pt)[*Legend*]
    #v(-10pt)
    #table(
      columns: 4,
      stroke: none,
      box(line(
        length: 1cm,
        stroke: (paint: colors.at(0), thickness: 2pt),
      )),
      text(size: 10pt)[#algos.at(0)],
      box(line(
        length: 1cm,
        stroke: (paint: colors.at(1), thickness: 2pt),
      )),
      text(size: 10pt)[#algos.at(1)],

      box(line(
        length: 1cm,
        stroke: (paint: colors.at(2), thickness: 2pt),
      )),
      text(size: 10pt)[#algos.at(2)],
    )
    #v(10pt)
    #text()[*_x-axis_ is $log_2("transform size")$*]
  ],
)
#let heads = (
  [*Techniques*],
  table.vline(),
  [*Total LUT*],
  table.vline(),
  [*Flip-Flops*],
  table.vline(),
  [*DSPs*],
  table.vline(),
  [*Power (mW)*],
  table.vline(),
  [*$F_"max"$ (MHz)*],
  table.vline(),
  [*Throughput (MSa/s)*],
  table.vline(),
  [*Latency (cycles)*],
)
#show table.cell.where(y: 0): set align(center)
#show table.header: set text(fill: red);
#figure(
  caption: [Comparison of various 16 point techniques],
  [#table(
      stroke: none,
      columns: (1.5fr, .8fr, 1fr, .8fr, 1fr, 1fr, 1.5fr, 1.2fr),
      table.header(..heads),
      table.hline(),
      [In-place],
      [1611],
      [555],
      [4],
      [104],
      [79.2],
      [#Throughput.at(0).at(1)],
      [49],

      [R2MDC],
      [419],
      [645],
      [12],
      [187],
      [137.1],
      [274.2],
      [10],

      [R2SDC],
      [516],
      [327],
      [12],
      [154],
      [118.3],
      [118.3],
      [17],

      [Winograd],
      [2330],
      [2850],
      [20],
      [208],
      [136.4],
      [136.4],
      [19],
    )
  ],
)

- R2MDC seems to be high performing algorithm
- However it and SDC needs buffer and reorderer in subsequent sections

== Comparison of scalable techniques
#figure(
  image("images/res1.svg", width: 100%),
  caption: [Resource and performance analysis of scalable techniques.],
	kind: image,
)
#figure(
  image("images/res2.svg", width: 100%),
  caption: [Resource and performance analysis of scalable techniques.],
	kind: image,
)
#figure(
  image("images/res3.svg", width: 80%),
  caption: [Resource and performance analysis of scalable techniques.],
	kind: image,
)


= Conclusion 
- Evaluated FFT techniques and their resource utilization on an Artix-7 FPGA.
- Choice of technique depends heavily on specific performance (latency, throughput, etc.), hardware constraints, etc. 
#v(10pt)
- *In-place Radix-2 DIT*: Burst architecture, For low power, low speed systems.
- *R2MDC*: for high-throughput systems in which input data is available ahead of time. Outputs in bit-reversed order.
- *R2SDC*: Burst architecture. uses roughly half the FF of MDC. The outputs are in bit-reversed order.
- *Winograd*: Used in cases where hardware multipliers are scarce. Not well suited for FPGA


= Future scope
- Use of built in BRAM for reducing number of FF (codebase will not be tool/platform agnostic)
- Optimizing existing implementation
- Further routing can be reduced by considering case of real valued signals. 
#focus-slide()[
  #place(left + top)[#rect(
    width: 100%,
    height: 100%,
    fill: pc.transparentize(20%),
  )]
  #text(weight: "semibold")[Thank you]
]
