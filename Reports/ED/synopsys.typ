#set text(font: "MLMRoman12", size: 13pt, lang: "en", region: "IN")
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set page(numbering: "1")
#set text(size: 11pt)
#show heading.where(level: 1): set text(size: 13pt)
#show heading.where(level: 2): set text(size: 13pt)
#show heading.where(level: 3): set text(size: 11.5pt)
#show heading.where(level: 3): set heading(outlined: false)

#counter(page).update(1)
#align(center)[
  #text(size: 16pt)[Project Synopsis:]\
  
  *Submitted by Group 6: * \
    Noyal K N, 
    Prabhath C S, \
    Pravan Praveen, 
    Roopesh O R, \
    Roshna Palatty Santhosh
  
  #text(size: 14pt)[PackCheck: Portable EV Battery Diagnostic and Charging Tool]
]

#set par(first-line-indent: 11pt, leading: .65em, spacing: 1.3em, justify: true)

#let SP = 8000;
#let FC = 14000;
#let VC = 4284;
#let targetUnitSelling = 20;
#let investment = 604000 + targetUnitSelling * VC;
#let CM = SP - VC;
#let CM = SP - VC;
#let BEP_u = calc.ceil(FC/CM);
#let inv-payback-time = calc.round(investment/(CM *(targetUnitSelling - BEP_u)))
#let profit-margin = (CM * targetUnitSelling - FC)/(SP * targetUnitSelling) ;

= Description
PackCheck is a handheld electronic diagnostic and cell-balancing tool targeted towards EV repair shops. It can connect directly to standard 48V–72V Lithium-ion battery packs with and have variety of interfacing options. It can identify individual cell voltages, identify weak cells, measure State of Health and internal resistance. The device has an option to balance the cells to equalize the power distribution as well as charge the battery pack. It also has a 2-inch LCD for showing diagnostics. The product serves as a "first-aid" kit for EV batteries, which help to extend the usefulness of the battery. 

= Techno-economic feasibility & Survey
Primary electronic components (microcontroller, sensing ICs, MOSFETs, etc.) are off-the-shelf and readily available from trusted distributors like DigiKey. PCB fabrication can be outsourced to fab houses (local, or bulk ordering from Chinese manufacturers). At present ordering from maufacturers like JLC PCB is most cost effective. They are also very reliable. Through this, internal processes can be cut to just final assembly, testing, and firmware flashing.

In terms of economic feasibility, we have kept a high contribution margin per unit, allowing the business to hit BEP by 6 days, with an estimated investment payback period of #inv-payback-time months.

We identified similar products in the market, but they are in the price range of ₹9k-₹15k. Hence, our product has a attractive price option.

== Cost & Profit margin
To reduce cost, we plan to utilise land available with us instead of purchasing separate. Here the location chosen is Kothamangalam.
For building, we are going with lightweight PEB (Pre-Engineered Building) shed with steel trusses and GI roofing.
// [
// #image("image.png", width: 10cm)
// We are going to make single floor 800 sq.ft. building. The estimated foundation work is 1.6L (assuming around ₹200/ft price). GI roofing will cost approx ₹56,000 (₹50/$"ft"^2$ and taking 20% more space than the ground) including labour. Electrification is ₹50/sq.ft so cost is 40000. For walls EPS Sandwich Panels can be used, costing about sqrt(800)ft \* 4 \* 3m (height) \* 160 = 1.7L. For furniture, ESD-Safe Workbenches: 12k \* 2 tables + 8000 for additional stuffs.

// For registering stamp duty, etc costs approx 20k. Factory license \~ 700. Fire and safety clearance 26000. Pollution: 4400. total clearance charge is 52k.

// Equipments: Soldering station: 4 (3500 each), Hot Air Rework station: 3500 (3 count), ESD safe tweezers, cutters, DC supply (8000, 1 no), programmable DC electronic load (23k, 1no), Digital Multimeters (4 \* 2000), Flashers (2k \* 1). Total 67k
// ]
#align(center)[
#grid(
  columns: (1fr, 1.4fr, 1fr),
  column-gutter: 10pt,
  [
    #underline[Total cost per product]
    #table(
      columns: 2,
      align: left,
      [Electronics], [3680],
      [Packaging], [400],
      [Variable cost], [5%],
      [Total], [*₹4284*]
    )
  ],[
    #underline[Initial investment]
    #table(
      columns: (2fr,1fr),
      align: left,
      // [#h(4pt)foundation & floor], [1,60,000],
      // [#h(5pt)Roofing]           , [56,000],
      // [#h(5pt)Electrification]   , [40,000],
      // [#h(5pt)Walls]             , [1,70,000],
      // [#h(5pt)Doors, windows]    , [7,000],
      // [#h(5pt)Furnitures]        , [32,000],
      [Building cost], [*4,65,000*],
      [Equipments], [67,000],
      [Clearance charges], [\~52,000],
      [Initial Material Cost], [#(VC * targetUnitSelling)],
      [Buffer], [20,000],
      [*Total*], [*₹6,89,680*]
    )
  ],[
    #underline[per-month operational cost]
    #table(
      columns: 2,
      align: left,
      [Electricity], [8,000],
      [Water], [1,000],
      [Insurance], [4,000],
      [Maintenance], [1,000],
      [*Total*], [*₹14,000*]
    )
  ]
)]
We are planning to pool initial investment from us founders. Each one is investing 1.38L. One of us is providing land. Hence the partnership contribution adjusts accordingly.

We are setting a Selling Price of: ₹#SP/unit.

Here contribution margin is $₹#SP - ₹VC = ₹#CM$

= Break Even Point (BEP)

$ "BEP in units" = (#FC)/(CM) approx #BEP_u "units/month" $
$ "BEP in revenue" = SP * #BEP_u = ₹#(SP * BEP_u) $


#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4": plot

#let xmax = targetUnitSelling;

#figure(
  cetz.canvas({
    plot.plot(
      size: (9, 5),
      x-label: [Quantity (Units)],
      y-label: [Amount (₹)],
      x-min: 0, x-max: xmax,
      // y-min: 0, y-max: 1100000,
      legend: "north-east",
      {
        // 1. Fixed Cost line (₹1,55,600)
        plot.add(
          domain: (0, xmax),
          x => FC,
          label: [Fixed Cost (₹#FC)],
          style: (stroke: (paint: red))
        )

        // 2. Total Cost line (1,55,600 + 4,250 * x)
        plot.add(
          domain: (0, xmax),
          x => FC + VC * x,
          label: [Total Cost (VC: ₹#VC)],
          style: (stroke: (dash: "dash-dotted", thickness: 1pt))
        )

        // 3. Total Revenue line (6,000 * x)
        plot.add(
          domain: (0, xmax),
          x => SP * x,
          label: [Total Revenue (SP: ₹#SP)],
          style: (stroke: blue + 1pt, dash: (10pt, 2pt, "dot", 2pt))
        )

        plot.add-fill-between(
          domain: (BEP_u, xmax),
          x => SP * x,
          x => FC + VC * x,
          style: (
            fill: green.transparentize(50%),
            stroke: none,
          ),
        )

        plot.add-fill-between(
          domain: (0, BEP_u),
          x => SP * x,
          x => FC + VC * x,
          style: (
            fill: red.transparentize(50%),
            stroke: none,
          ),
        )

        // 4. BEP Projection Lines (Q = 88.91 units, R = ₹5,33,486)
        // 155600/(8000-4250) =  x
        plot.add(
          (
            (BEP_u, 0),
            (BEP_u, BEP_u* SP),
            (0, BEP_u* SP)),
          style: (stroke: (paint: green))
        )

        // 5. BEP Marker
        plot.add(
          ((BEP_u, BEP_u* SP),),
          mark: "*",
          mark-style: (fill: orange, stroke: black),
          label: [BEP (#BEP_u units, ₹#(BEP_u * SP))]
        )
      }
    )
  }),
)

We are expecting sales of #targetUnitSelling units/month; in this case the initial investment is expected to be recovered by :
$ (₹investment)/(₹#CM"/unit" * (#targetUnitSelling "units" -#BEP_u "units")) approx #inv-payback-time "months" $

After the payback the net profit margin is:
$
"Net income"/"Net revenue" = (₹#CM times #targetUnitSelling  - ₹#FC)/(₹#SP times #targetUnitSelling) times 100%= bold(#(calc.round(profit-margin * 100 * 100)/100)%)
$

= CPM diagram
#v(1cm)

#{
  set text(size: 6pt, font: "PT Sans")
  let bent-edge(from, to, ..args) = {
  let midpoint = (from, 50%, to)
  let vertices = (
    from,
    (from, "-|", midpoint),
    (midpoint, "|-", to),
    to,
  )
  edge(..vertices, "-|>", ..args)
}

let cpm_s = 0.75pt+rgb("#0c88af");
let cpm_f = rgb("#cae8fc");
let cnode(pos, txt, ..args) = {
  node(pos, txt, fill: cpm_f, stroke: cpm_s, shape: fletcher.shapes.rect, ..args)
}
  diagram(
    node-stroke: 1pt+black,
    edge-stroke: 0.75pt+black,
    node-corner-radius: 3pt,
    mark-scale: 70%,
    edge-corner-radius: 0pt,
    node((0mm, 0mm), [Start], shape: fletcher.shapes.ellipse, name: <O>),
    node((rel: (2cm, 3cm)), [J: Clearance \ 3 weeks], name: <J>),
    cnode((rel: (0cm, -1.2cm)), [A: Site prep \ 4 weeks], name: <A>),
    cnode((rel: (2.6cm, 0cm)), [F: PCB Assembly \ & FW flashing \ 4 days],name: <F>),
    cnode((rel: (2.5cm, 0cm)), [G: Final Assembly \ 3 day], name: <G>),
    cnode((rel: (2.2cm, 0cm)), [H: Testing \ 1 day], name: <H>),
    cnode((rel: (2.2cm, 0cm)), [I: Packaging \ & Shipping \ 1 day], name: <I>),
    
    node((rel: (2.07cm, .7cm), to: <O>), [B: PCB Order\ 3 week], name: <B>),
    node((rel: (0.06cm, -1.3cm)), [C: Equipments\ Order \ 2 weeks], name: <C>),
    node((rel: (0.06cm, -1.3cm)), [D: Components\ Order\ 2 week], name: <D>),
    node((rel: (0.16cm, -1.2cm)), [E: Enclosure Order\ 2 week], name: <E>),
    
    edge(<A>, <F>, "-|>", stroke: cpm_s),
    edge(<F>, <G>, "-|>", stroke: cpm_s),
    edge(<G>, <H>, "-|>", stroke: cpm_s),
    edge(<H>, <I>, "-|>", stroke: cpm_s),
    
    bent-edge(<O.east>, <J.west>),
    bent-edge(<O.east>, <D.west>),
    bent-edge(<O.east>, <E.west>),
    bent-edge(<O.east>, <C.west>),
    bent-edge(<O.east>, <B.west>),
    bent-edge(<O.east>, <A.west>, stroke: cpm_s),
    edge(<J.east>, (<J.east>, "-|", <F.north>), <F.north>, "-|>"),
    edge(<E.east>, (<E.east>, "-|", <G.south>), <G.south>, "-|>"),
    edge(<D.east>, (<D.east>, "-|", <F.north>), <F.south>, "-|>"),
    edge(<C.east>, (<C.east>, "-|", <F.north>), <F.south>, "-|>"),
    edge(<B.east>, (<B.east>, "-|", <F.north>), <F.south>, "-|>"),
    
  );
}

Critical Path is: $A arrow F arrow G arrow H arrow I$

Total estimated project Duration is 37 Days. 