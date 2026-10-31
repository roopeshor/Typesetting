#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let mccf-flow = {
  set text(font: "Fira Sans", size: 9pt)
  diagram(
      node-shape: fletcher.shapes.rect,
      node-corner-radius: 5pt,
      node-stroke: .75pt,
      edge-stroke: 1pt,
      let nodeD(pos, cnt, id, fl: blue.lighten(80%)) = {
        node(
          (rel: pos),
          text(fill: black)[#cnt],
          shape: fletcher.shapes.cylinder,
          name: id,
          fill: fl,
        )
      },
      node((0, 0), [Raw Data]),
      edge("-|>", [FFT]),
      node((rel: (1, 0)), [Spectrum]),
      edge("-|>"),
      node((rel: (.8, 0)), [DC\ masking]),
      edge("-|>", [IFFT]),
      node((rel: (1, 0)), [Time\ Series]),
      edge("-|>"),
      node((rel: (.9, 0)), [Set ST\ Window], name: <st>),
      nodeD((.8, -.8), [ST window Array], <st_dat>),
      edge(<st.north>, "->", <st_dat.west>, bend: 50deg),
      edge(<st.east>, "-|>", <mc_node.west>),
      node((rel: (.35, .8)), [Mutual\ Convolution], name: <mc_node>),
      edge("-|>"),
      node((rel: (0, 2)), [MCLMS Filter], name: <mclms_node>),
      nodeD((-.3, .9), [Denoised Spectra], <spec_dat>),
      edge(<mclms_node.south>, "->", <spec_dat.north>, bend: 10deg),
      edge(<mclms_node.west>, "-|>", <cps_node.east>),
      node((rel: (-.3 - .6, -.9)), [Candiate Peak\ Selection], name: <cps_node>),
      nodeD((-1.2, -1), [Peaks array], <peaks_dat>),
      nodeD((0, 2), [Cost Array], <cost_dat>),
      edge(<cps_node.west>, "-->", <st.south-west>, bend: 50deg),
      edge(<cps_node.west>, "-|>", <me_node.east>),
      edge(<cps_node.west>, "->", <peaks_dat.south>, bend: 20deg, [peak], label-pos: .4, label-side: center),
      edge(<cps_node.south>, "->", <cost_dat.east>, bend: 20deg, [cost], label-pos: .6, label-side: center),
      node((rel: (.8 - 1.2, -1)), [Moment estimation], name: <me_node>),
      edge("->"),
      nodeD((-1, 0), [*Moments\ $M_0$ $M_1$ $M_2$*], <res_blk>, fl: green.lighten(70%)),
    )}