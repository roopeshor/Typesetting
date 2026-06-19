= Comparison
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4"
#import "@preview/numty:0.1.0" as nt



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

#let Throughputs = ()
#let TPconsts = (
  nt.div(2, (3, 4, 5, 6)),
  (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
  (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
)
#for i in range(Fmax.len()) {
  let t = ()
  let fm = Fmax.at(i)
  Throughputs += (nt.mult(fm, TPconsts.at(i)),)
}

// #Throughputs.len()
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
  "BRAM": BRAM,
  "DSPs/N": DSP-per-N,
  "Power": Power,
  "Fmax": Fmax,
  // "Throughputs": Throughputs,
)
#let y-units = (
  "Total LUTs/N": "units",
  "SLR*/N": "units",
  "Flip-Flops/N": "units",
  "RAMB36": "units",
  "RAMB18": "units",
  "BRAM": "units",
  "DSPs/N": "units",
  "Power": "mW",
  "Fmax": "MHz",
  "Throughputs": "MHz",
)

#let plot-graph(i) = {
  let plots = plots-to-do.at(i)
  cetz.canvas({
    import cetz.draw: *
    import cetz-plot: *
    content((3, 4.3), text()[#i])
    plot.plot(
      size: (6, 4),
      axis-style: "scientific",
      x-label: "",
      y-label: y-units.at(i),
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

All datas have been plotted here for quick comparison:
#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    let dy = 3
    let A = algos.len()
    content((-dy / 2 - 1, 0), text(size: 11pt)[*Legend: *], anchor: "west")
    rect((-dy / 2 - 1.2, -.4), (A * dy - dy / 4, .5))
    for j in range(A) {
      line((j * dy, 0), (j * dy + .9, 0), stroke: colors.at(j))
      content((j * dy + 1, 0), text(size: 10pt)[#algos.at(j)], anchor: "west")
    }
  })]

#grid(
  columns: 2,
  column-gutter: 30pt,
  row-gutter: 10pt,
  align: right,
  ..plots-to-do.keys().map(i => plot-graph(i))
)

The throughput is not plotted here as it closely matches with $F_max$.
From this we its clear that inplace algorithm performs worse in all cases except at power consumption. Also MDC architecture is prefered in high throughput requirements (such as radar, SDR, etc.). With both pipelined architectures, the synthesis tool was able to infer BRAM blocks past a certain number of transform size.