= Comparison <comparison>
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


== Comparison of 16 point transforms
To include Winograd in the comparison, case of 16 point transforms and their parameters are listed in @tabl:comp.
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
)<tabl:comp>

// #cetz.canvas({
//   import cetz.draw: *
//   import cetz-plot: chart
//   set-style(
//     legend: (fill: white),
//     barchart: (bar-width: 1, cluster-gap: 0),
//     axes: (
//       bottom: (
//         tick: (label: (angle: 40deg, anchor: "east")),
//       ),
//     ),
//   )
//   chart.barchart(
//     mode: "clustered",
//     size: (6, auto),
//     label-key: 0,
//     value-key: (..range(1, 5),),
//     (([Total LUT], 1611, 419, 516, 2330),),
//   )
// })

In this case also R2MDC seems to have better edge over all other techniques. But this power only comes handly when all data are available readily. However in most practical cases data is being continously fetched from realworld, making throughput of MDC unusable. Winograd and R2SDC are the next to consider. Winograd takes consumes significantly higher number of hardware resources in order to reduce multiplications. Perhaps my implementation might not me very efficient. Depending on pipeline depth the maximum operating frequency of winograd can be between 136.8 MHz to 142.8 MHz. However deeper pipelining increases latency.

== Comparison of scalable techniques
The resource and performance of scalable techniques are shown in @fig:scal-ref. Same number of DSPs are required for SDC and MDC. Since In-place technique is non-pipelined, throughput is computed as $F_"max" \/ (2+ log_2(N)\/2)$ as one compute frame is $2N + N log_2(N)\/2$ cycles long and no input can be supplied during this frams.
From the graphs it is clear that inplace algorithm performs worse in all cases except at power consumption. Also MDC architecture is preferred in high throughput requirements (such as radar, SDR, etc.). With both pipelined architectures, the synthesis tool was able to infer BRAM blocks past a certain number of transform size. For inplace technique, performance was not calculated for transform sizes greater than 64. (At higher number of points, the design was not synthesizable due to increased number of components and complexity). The maximum frequency drops as transform size increases. This might be due to the longer paths in the FPGA required to connect extensive.
#show figure: set block(breakable: true, spacing: 15pt)
#figure(
  gap: 1pt,
  caption: [Resource and performance analysis of scalable techniques.],
	kind: image,
  grid(
    columns: 2,
    column-gutter: 30pt,
    row-gutter: -4pt,
    align: right,
    ..grd
  ),
)<fig:scal-ref>
