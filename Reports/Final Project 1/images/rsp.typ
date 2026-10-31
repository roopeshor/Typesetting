#import "@preview/cetz:0.5.3"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let rsp-chain-fig = {
  set text(font: "PT Sans", size: 10pt)
  set par(justify: false)
  let dedge() = {
    edge("-|>", shift: -10pt)
    edge("-|>", shift: 10pt)
  }
  let dedge2(a, b, c) = {
    edge(a, b, c, "-|>", shift: -10pt)
    edge(a, b, c, "-|>", shift: 10pt)
  }
  diagram(
    node-shape: fletcher.shapes.rect,
    node-corner-radius: 2pt,
    node-stroke: .75pt,
    edge-stroke: 1pt,
    node-inset: 8pt,

    node(
      (-2.5cm, 0cm),
      image("antenna.pdf", width: 1cm),
      stroke: none,
      name: <rsp-f-o>,
      inset: 5pt,
    ),
    node((0pt, 0pt), [ADC], height: 1.3cm, name: <rsp-f-adc>),
    edge(<rsp-f-o>, <rsp-f-adc>, "-|>"),
    dedge(),
    node((rel: (2cm, 0pt)), [DDC], height: 1.3cm),
    dedge(),
    node((rel: (2.4cm, 0pt)), [Decoding], height: 1.3cm),
    dedge(),
    node((rel: (2.9cm, 0pt)), [Range\ Averaging], height: 1.3cm),
    dedge(),
    node((rel: (3cm, 0pt)), [Coherent\ Integration], name: <rsp-f-ci>),
    node((rel: (3cm, -3cm)), [Windowing], name: <rsp-f-win>, height: 1.4cm, inset: 5pt),
    dedge2(<rsp-f-ci.east>, (<rsp-f-ci.east>, "-|", <rsp-f-win.north>), <rsp-f-win.north>),
    edge("-|>"),
    node((rel: (-3cm, 0cm)), [#text(size: 1em)[Power  Spectrum\ Estimation]], height: 1.5cm, inset: 4pt),
    edge("-|>"),
    node((rel: (-3cm, 0cm)), [Clutter\ Removal], height: 1.4cm),
    edge("-|>"),
    node((rel: (-2.2cm, 0cm)), [NCI], height: 1.4cm, name: <f-NCI>),
    edge("-|>"),
    node((rel: (-2.2cm, 0cm)), [Noise Level\ Estimation], height: 1.5cm),
    edge("-|>"),
    node((rel: (-2.8cm, 0cm)), [Spectral\ Moments], height: 1.5cm),
    edge("-|>"),
    node((rel: (-2.6cm, 0cm)), [UVW\ estimation], height: 1.5cm, inset: 4pt, name: <rsp-f-uvw>),

    node((rel: (18pt, 25pt), to: <rsp-f-win.north>), [$Q$], stroke: none, name: <rsp-f-q>),
    node((rel: (-18pt, 25pt), to: <rsp-f-win.north>), [$I$], stroke: none, name: <rsp-f-i>),

    node(
      enclose: (<rsp-f-adc>, <rsp-f-ci>),
      shape: rect,
      fill: blue.transparentize(95%),
      stroke: (dash: "dashed", thickness: 1.5pt, paint: blue),
      inset:  15pt,
      layer: -1,
      name: <rsp-f-rsp-b>,
    ),
    node(
      (rel: (0pt, 10pt), to: <rsp-f-rsp-b.north>),
      text(fill: blue)[*Radar Processing Computer*],
      stroke: none,
    ),
    let gr = rgb("#0b8110"),
    node(
      enclose: (<rsp-f-uvw>, <rsp-f-win>, ),
      shape: rect,
      fill: gr.transparentize(95%),
      stroke: (dash: "dashed", thickness: 1.5pt, paint: gr),
      inset:  12pt,
      layer: -1,
      name: <rsp-f-rsp-g>,
    ),
    node(
      (rel: (0pt, -10pt), to: <rsp-f-rsp-g.south>),
      text(fill: gr)[*Main Algorithm*],
      stroke: none,
    ),
  )
}
