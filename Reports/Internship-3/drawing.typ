#import "@preview/cetz:0.5.2"

#let bit-reverse(x, bits) = {
  let r = 0
  let temp = x
  for _ in range(bits) {
    r = r * 2 + calc.rem(temp, 2)
    temp = calc.quo(temp, 2)
  }
  r
}

// -------------------------------------------------------------------------
// Corrected FFT Addressing Logic
// -------------------------------------------------------------------------
#let fft-addr(si, stage) = {
  // Gap doubles with each stage: 1, 2, 4, etc.
  let gap = calc.pow(2, stage)

  // Find which butterfly group this node belongs to
  let group-idx = calc.quo(si, gap)
  let offset = calc.rem(si, gap)

  // Calculate top (a) and bottom (b) node indices
  let a = group-idx * (gap * 2) + offset
  let b = a + gap

  (a, b)
}

#let bf_edge(x1, y1, x2, y2, middle: "", neg-offset: 0.9, neg-font-size: 8pt) = {
  import cetz.draw: *

  if middle != "" {
    let e1 = (x1 + (x2 - x1) * neg-offset, y1 + (y2 - y1) * neg-offset)
    line((x1, y1), e1, mark: (end: "straight"), name: "ln")
    content(
      "ln.90%",
      anchor: "north",
      padding: 5pt,
      text(middle, size: neg-font-size),
    )
  }

  circle((x1, y1), radius: 2pt, fill: white)
  circle((x2, y2), radius: 2pt, fill: white)
}

#let get-twiddle-k(n, s, N) = {
  let log2-N = calc.round(calc.log(N, base: 2))
  let local-idx = calc.rem(n, calc.pow(2, s))
  let stride = calc.pow(2, log2-N - 1 - s)
  local-idx * stride
}

#let butterfly(
  N,
  si,
  stage,
  stages,
  x,
  h-scale: 2,
  v-scale: 1,
  neg-offset: 0.9,
  tw-offset: 0.7,
  neg-font-size: 8pt,
  bf-gap: 1,
  skip-unit-twiddle: false,
  show-twiddle: true,
  twiddle-pos: "left",
) = {
  import cetz.draw: *

  let (a, b) = fft-addr(si, stage)
  let x2 = x + h-scale
  let ya = a * v-scale
  let yb = b * v-scale

  line((x, ya), (x2, yb))
  line((x, yb), (x2, ya))

  bf_edge(x, ya, x2, ya, neg-offset: neg-offset, neg-font-size: neg-font-size)
  bf_edge(x, yb, x2, yb, middle: "-1", neg-offset: neg-offset, neg-font-size: neg-font-size)

  let ex = get-twiddle-k(si, stage, N)
  if not (skip-unit-twiddle and ex == 0) and show-twiddle {
    let twiddle-lbl = text(math.equation($W_(#N)^(#ex)$), size: neg-font-size)
    if twiddle-pos == "left" {
      let e1 = (x - bf-gap * (1 - tw-offset), yb)
      line((x - bf-gap, yb), e1, mark: (end: "straight"), name: "ln")
      content("ln.90%", anchor: "north", padding: 5pt, twiddle-lbl)
    } else {
      let e1 = (x2, yb)
      line(e1, (x2 + bf-gap * tw-offset, yb), mark: (end: "straight"), name: "ln")
      content("ln.90%", anchor: "north", padding: 5pt, twiddle-lbl)
    }
  }
}

// -------------------------------------------------------------------------
// Core Layout Engine
// -------------------------------------------------------------------------
#let _draw-fft(
  is-dit: true,
  N: 8,
  h-scale: 3,
  v-scale: 1.2,
  neg-offset: 0.9,
  neg-font-size: 8pt,
  bf-gap: 1,
  show-twiddle: true,
  skip-unit-twiddle: false,
  in-labels: (),
  out-labels: (),
  remove-last-pad: false,
) = {
  import cetz.draw: *
  scale(y: -1)

  let n = calc.ceil(N / 2)
  let stages = calc.ceil(calc.log(n, base: 2))
  let x2 = if remove-last-pad { (h-scale) * (stages + 1) + +bf-gap * stages } else { (h-scale + bf-gap) * (stages + 1) }

  // Parallel horizontal lines and node labels
  for si in range(0, N) {
    let y = si * v-scale
    line((0, y), (x2, y))

    let ta = bit-reverse(si, stages + 1)
    let (left-val, right-val) = if is-dit {
      (math.equation($x(#ta)$), math.equation($X(#si)$))
    } else {
      (math.equation($x(#si)$), math.equation($X(#ta)$))
    }
    if (in-labels.len() == N) {
      left-val = in-labels.at(si)
    }
    if (out-labels.len() == N) {
      right-val = out-labels.at(si)
    }

    content((0, y), anchor: "east", padding: 4pt, left-val)
    content((x2, y), anchor: "west", padding: 4pt, right-val)
  }

  // Connect butterflies
  for stage in range(0, stages + 1) {
    for si in range(0, n) {
      let actual-stage = if is-dit { stage } else { stages - stage }
      let x-pos = stage * h-scale + bf-gap * if is-dit { stage + 1 } else { stage }

      butterfly(
        N,
        si,
        actual-stage,
        stages,
        x-pos,
        h-scale: h-scale,
        v-scale: v-scale,
        neg-offset: neg-offset,
        neg-font-size: neg-font-size,
        bf-gap: bf-gap,
        show-twiddle: show-twiddle,
        skip-unit-twiddle: skip-unit-twiddle,
        twiddle-pos: if is-dit { "left" } else { "right" },
      )
    }
  }
}

// -------------------------------------------------------------------------
// Public Exports
// -------------------------------------------------------------------------
#let DIT-fft(
  N: 8,
  h-scale: 3,
  v-scale: 1.2,
  neg-offset: 0.9,
  neg-font-size: 8pt,
  bf-gap: 1,
  skip-unit-twiddle: false,
) = {
  if calc.pow(2, calc.round(calc.log(N, base: 2))) != N {
    panic("Value of N must be a power of 2, given value: " + str(N))
  }

  cetz.canvas({
    _draw-fft(
      is-dit: true,
      N: N,
      h-scale: h-scale,
      v-scale: v-scale,
      neg-offset: neg-offset,
      neg-font-size: neg-font-size,
      bf-gap: bf-gap,
      skip-unit-twiddle: skip-unit-twiddle,
    )
  })
}

#let DIF-fft(
  N: 8,
  h-scale: 3,
  v-scale: 1.2,
  neg-offset: 0.9,
  neg-font-size: 8pt,
  bf-gap: 1,
  show-twiddle: false,
  skip-unit-twiddle: false,
  in-labels: (),
  out-labels: (),
) = {
  if calc.pow(2, calc.round(calc.log(N, base: 2))) != N {
    panic("Value of N must be a power of 2, given value: " + str(N))
  }

  cetz.canvas({
    _draw-fft(
      is-dit: false,
      N: N,
      h-scale: h-scale,
      v-scale: v-scale,
      neg-offset: neg-offset,
      neg-font-size: neg-font-size,
      bf-gap: bf-gap,
      show-twiddle: show-twiddle,
      skip-unit-twiddle: skip-unit-twiddle,
      in-labels: in-labels,
      out-labels: out-labels,
    )
  })
}

#let textc(txt) = box(align(center)[#txt]);

{
#import "@preview/circuiteria:0.2.0": circuit, element, util, wire
#let vwire(wn, d1, d2, r: 40%) = wire.wire(
  wn,
  (d1, d2),
  directed: true,
  style: "zigzag",
  zigzag-dir: "vertical",
  zigzag-ratio: r,
)
#let hwire(wn, d1, d2, r: 40%) = wire.wire(
  wn,
  (d1, d2),
  directed: true,
  style: "zigzag",
  zigzag-dir: "horizontal",
  zigzag-ratio: r,
)
}
