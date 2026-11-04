#set text(font: "MLMRoman12", size: 13pt)
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

////// Title
  
#align(center+horizon)[
  #text(size: 20pt)[*Entrepreneurship Development*]

  Project Report on
  
  #text(size: 18pt)[*PackCheck: Portable EV Battery Diagnostic and Charging Tool*]

  #v(1cm)
  #image("cusat.svg", width: 4cm)
  
  #v(.5cm)

  _Submitted by:_
  
    *Group 6*\
    Noyal K N\
    Prabhath C S\
    Pravan Praveen\
    Roopesh O R\
    Roshna Palatty Santhosh

  #v(1cm)

  #text(size: 17pt)[
    *Division of Electronics and Communication Engineering* \
  ]

  #v(.5cm)
  
  November 2026
  
]


#pagebreak()

//// Abstract
#set page(numbering: "1")
#set text(size: 11pt)

#set heading(numbering: "1.")
#show heading.where(level: 1): set text(size: 16pt)
#show heading.where(level: 2): set text(size: 13pt)
#show heading.where(level: 3): set text(size: 11.5pt)
#show heading.where(level: 3): set heading(outlined: false)
#set par(first-line-indent: 11pt, leading: .65em, spacing: 1.3em)
#counter(page).update(1)
#align(center)[
  #text(size: 16pt)[PackCheck:\ Portable EV Battery Diagnostic and Charging Tool]
]
#v(1cm)

#set par(first-line-indent: 11pt, leading: .65em, spacing: 1.3em, justify: true)

#let SP = 8000;
#let VC = 4389;
#let rent = 20000;
#let FC = 14000 + rent;
#let targetUnitSelling = 30;
#let IMC = VC * targetUnitSelling;
#let investment = 171000 + IMC;
#let CM = SP - VC;
#let BEP_u = calc.ceil(FC/CM);
#let inv-payback-time = calc.round(investment/(CM *(targetUnitSelling - BEP_u)))
#let profit-per-month = CM * targetUnitSelling - FC;
#let profit-margin = (profit-per-month)/(SP * targetUnitSelling) ;

#outline(
  title: block(
    width: 100%,
    inset: (bottom: 5pt),
    stroke: (bottom: 0.5pt + black)
  )[
    #text(size: 14pt, weight: "regular")[Contents]
  ]
)
#v(1cm)

= Introduction
Electric two-wheeler and three-wheeler vehicles are becoming a common sight on Kerala's roads. With this shift comes a maintenance problem that the existing repair ecosystem was not built for. An electric vehicle hides its most expensive and failure-prone component, the battery pack, insideckde a sealed casing, and the symptoms of a failing pack (reduced range, sudden voltage drops, uneven charging) can have several different causes.
Most independent garages in the state have limited ways of looking inside the pack. The usual outcome is a recommendation to replace the entire battery, even when only a small part of it has failed.
PackCheck is proposed as a solution to this gap. It is a handheld diagnostic and cell-balancing tool designed for EV repair shops, battery assemblers and delivery fleet hubs. It connects to standard 48V to 72V lithium-ion packs, reads the voltage of every individual cell, identifies weak cells, estimates State of Health and internal resistance, balances the pack, and can charge it.

= Product Description
PackCheck is a portable, handheld unit with a 2-inch LCD display. It is intended to be a portable workbench tool, connected to the pack through its balance leads and main terminals, and read directly by the technician without a laptop or phone. The product is meant to work as a "first-aid kit" for EV batteries: quick to set up, simple to read, and capable of delivering a corrective action as well as a diagnosis. When a technician receives a vehicle with a range complaint. The battery pack is disconnected from the vehicle, and PackCheck is connected to its terminals and balance leads. Shortly, the screen shows details about the battery pack and individual cells. The technician can balance cells if required. If one or two cells have collapsed, the report identifies them, and the shop can quote a cell replacement instead of a new pack. 
The device can perform four functions:

- *Cell-level voltage measurement*: Each cell group in the pack is measured individually. For a typical 16S pack, this means sixteen readings, displayed together so that the technician can see at a glance which cells sit above or below the rest.
- *Weak-cell identification*: By comparing each cell with the pack average and with its neighbours, the device can flag cells that are drifting, underperforming, or have collapsed. This is a capability that a standard multimeter cannot offer, because a multimeter can only see all cells at once.
- *State of Health and internal resistance estimation*: Internal resistance is a widely used indicator of cell ageing. A cell with high internal resistance heats up under load and drops in voltage quickly, which the rider experiences as lost range and weak acceleration. PackCheck measures this value for the cells and uses it, along with the voltage data, to report an overall State of Health figure for the pack.
- *Balancing and charging*: Once an imbalance is found, the device can equalise the cells so that the pack delivers power evenly. It can also charge the pack, which allows a shop to complete a rebalancing cycle without a separate charger.

The tool supports a range of interfacing options so that it can be used with the different pack designs found in the local market. The wide voltage range means a single device can serve a multi-brand garage rather than requiring a different tool for each manufacturer.

The design uses off-the-shelf parts: a microcontroller for control and calculation, sensing ICs for cell measurement, MOSFETs for balancing and switching, a power stage for charging, and the LCD for output. Using standard components keeps the unit cost low and makes the bill of materials easy to source.

= Market Survey
The target market consists of:

- *Independent Multi-Brand EV Garages*: Local mechanics transitioning from ICE (petrol scooters/autos) to electric vehicles who lack diagnostic expertise.

- *Local Battery Pack Assemblers & Refurbishers*: Small businesses building or repairing custom 48V–60V lithium-ion packs for e-rickshaws and delivery fleets.

One question might arise: won't EV Repair Shops Already Have a Checker? Most local repair shops do not have a proper cell-level diagnostic and balancing tool. Because:

- Traditional mechanics use a basic ₹500 digital multimeter. It is cheaper. But it only shows total pack voltage, failing to reveal individual failing cells or pack imbalance hidden inside a sealed 16S casing.

- High-end multi-brand diagnostic tools (like imported OBD/BMS scanners) cost upwards of ₹50,000 to ₹1,00,000+, making them unaffordable for standard roadside garages.

- The "Replace vs. Repair" Problem: Without a specialised balancing and diagnostic tool, shops tell customers to throw away an entire ₹30,000 battery pack just because 2 out of 16 cells are dead. Packcheck allows shops to pinpoint the weak cell, rebalance the pack, and charge a service fee—saving money for the end-user. This also creates a good customer impression, and more people are likely to approach the service centres.
Next is how large the market is. From our research, the market is expanding:
- *Exploding EV market*: Kerala leads India in personal EV penetration, with electric two-wheeler and three-wheeler sales doubling year-on-year (https://www.theweek.in/news/biz-tech/2026/04/02/kerala-ev-sales-soar.html). Tens of thousands of EVs hit Kerala roads annually.
- *The 3-Year Replacement/Repair*: Lithium-ion batteries experience degradation after 2 to 3 years of heavy daily use (delivery fleets, daily commutes). They degrade by 15- 20% (https://evxpertz.com/blogs/battery-degradation-patterns-india ) under heavy use. Batteries sold during the 2023–2024 EV boom are now entering their end of warranty, creating a massive wave of repair demand right now.
- *Market Share*: Kerala has over 1,200+ registered EV service points and independent garages. Selling 20 to 30 units a month means capturing just 2% of the existing garages per year. Over a 3-year window, we will have penetrated less than 7% of the state's total repair market, making the idea relatively sustainable.

= Techno-economic feasibility
== Technical Feasibility
The main electronic components needed for PackCheck are standard commercial-off-the-shelf parts: a microcontroller, cell-sensing ICs, MOSFETs and supporting passive components. None of them is a specialised or restricted item. They are available from established distributors such as DigiKey, which reduces the risk of supply problems and means that alternative parts can be found if a particular component runs short.

The features of the product are also within the reach of conventional embedded design. Multi-channel cell voltage measurement, passive balancing and constant-current, constant-voltage charging are all established techniques. Internal resistance can be estimated from the voltage response of a cell to a known change in load current. The more demanding part of the work is calibration and firmware validation, and this will be carried out using the programmable DC electronic load and DC supply listed in the equipment plan.

== Manufacturing Approach
To keep the capital requirement low, PCB fabrication will be outsourced rather than done in-house. Options include local fabrication houses (one is available in Kakkanad) and bulk ordering from overseas manufacturers. At present, ordering from manufacturers such as JLCPCB is the most cost-effective option, and they have a good record of reliability and quality. Because of this, the in-house process is limited to final assembly, testing and firmware flashing. This reduces the space, staff and equipment needed.
== Economic Feasibility
The product has a high contribution margin. The unit cost is ₹#VC against a selling price of ₹#SP, which leaves a margin of ₹3,611 on every unit sold. The business reaches break-even at about ten units a month, or roughly nine to ten days of sales at the target volume, and the estimated payback period for the initial investment is about four months. Competitive pricing supports these numbers. Comparable products in the market are priced between ₹8,000 and ₹10,000, so a selling price of ₹8,000 puts PackCheck at the lower end of the range while still leaving a healthy margin, because the design avoids expensive proprietary parts. We have kept a high contribution margin per unit, allowing the business to hit BEP in #calc.round(BEP_u/targetUnitSelling * 28) days, with an estimated investment payback period of #inv-payback-time months.
We identified similar products in the market, but they are in the price range of ₹8k-₹10k. Hence, our product has an attractive price option.


= Product Cost & Initial Investment
== Product Cost
The cost of materials for one unit is given in Table 1.
#figure(
  caption: [Total cost per product],
  table(
    columns: (2fr, 1fr),
    align: (left, right),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { luma(240) } else { none },
    [*Component*], [*Cost (₹)*],
    [Microcontroller], [500],
    [Display], [1000],
    [Sensors], [640],
    [Power Supply], [400],
    [Other ICs], [740],
    [Auxillary components], [500],
    [Packaging], [400],
    [Variable cost], [5%],
    [*Total*], [*₹4389*]
  )
)
The 5 percent allowance covers wastage, small price variations and the cost of rejected
boards. The display is the largest single item, followed by the microcontroller and the
sensing components.
== Monthly Operating Cost 
#figure(
  caption: [per-month operational cost],
    table(
      columns: 2,
      align: left,
      [*Item*], [*Amount (₹)*],
      [Electricity], [8,000],
      [Water], [1,000],
      [Insurance], [4,000],
      [Maintenance], [1,000],
      [Rent], [#rent],
      [*Total*], [*₹#FC*]
    )
)
Rent is the largest part of the fixed cost, and it is the item that the later plan to build an
owned workshop is meant to remove.

== Investment
=== Production Facility
To reduce cost, the plan is to rent a workshop rather than buy or build one at the start. The chosen location is Kothamangalam. A space of about 500 square feet is estimated to be sufficient for assembly, testing and storage, and the monthly rent is estimated at ₹20,000.
The workshop needs two ESD-safe workbenches at ₹12,000 each (₹24,000 in total) to protect the electronics from electrostatic damage. A further ₹8,000 is set aside for additional items such as storage and lighting.
=== Statutory clearances (about ₹52,000).
Registration and stamp duty are estimated at about ₹20,000. The factory licence costs about ₹700, fire and safety clearance ₹26,000, and pollution clearance ₹4,400. The itemised amounts add up to roughly ₹51,100, which has been rounded to ₹52,000 in the budget to leave a small margin.

=== Equipments
The equipment list covers what is needed for assembly, rework, calibration and testing.

The programmable electronic load and the DC supply are the most important items, since they allow every unit to be tested against known conditions before dispatch. The flashers are used to load firmware onto each microcontroller.

#figure(
  caption: [Equipment List and Cost Breakdown],
  table(
    columns: (3fr, 1fr, 1.5fr, 1.5fr),
    align: (left, center, right, right),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { luma(240) } else { none },
    [*Equipment*], [*Quantity*], [*Unit cost (₹)*], [*Total (₹)*],
    [Soldering station], [4], [3,500], [14,000],
    [Hot air rework station], [3], [3,500], [10,500],
    [DC power supply], [1], [8,000], [8,000],
    [Programmable DC electronic load], [1], [23,000], [23,000],
    [Digital multimeter], [4], [2,000], [8,000],
    [Programmer / flasher], [1], [2,000], [2,000],
    [ESD-safe tweezers, cutters and small tools], [Lot], [1,500], [1,500],
    [*Total*], [], [], [*67,000*]
  )
)


=== Total investment
The starting capital covers furnishing, equipment, clearances, and enough material for the first month of production. Material for the first batch is calculated at 30 units, that is 30 × ₹4,389 = ₹1,31,670. A buffer of ₹20,000 is added for unforeseen costs.

#figure(
  caption: [Initial investment],
    table(
      columns: (2fr, 1fr),
    align: (left, right),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { luma(240) } else { none },
      [*Item*], [*Cost (₹)*],
      [Furniture], [32,000],
      [Equipment], [67,000],
      [Clearance charges], [\~52,000],
      [Initial Material Cost], [#IMC],
      [Buffer], [20,000],
      [*Total*], [*₹2,56,680*]
    )
)
The founders plan to pool this amount among themselves, so the project does not depend
on a loan or on outside investors at the start.


= Break-Even Point (BEP) and Profitability  
== Contribution Margin
The planned selling price is ₹8,000 per unit. After subtracting the variable cost of ₹4,389, each unit contributes $₹#SP - ₹VC = ₹#CM$

== Break-Even Point
The fixed cost to be covered each month is ₹34,000. The break-even volume is:
$ "BEP in units" = (#FC)/(CM) approx #BEP_u "units/month" $
$ "BEP in revenue" = SP * #BEP_u = ₹#(SP * BEP_u) $

In practical terms, the business covers all of its monthly costs once it has sold ten units. At the target of thirty units a month, this point is reached in about nine to ten days.


#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4": plot

#let xmax = targetUnitSelling;

#figure(
  caption: [Break Even Chart],
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
Revenue overtakes total cost at 10 units (₹80,000), and every unit sold beyond that point
adds ₹3,611 to profit.
== Payback Period
We are expecting sales of #targetUnitSelling units/month; the units sold above the break-even level contribute to recovering the initial investment. The monthly recovery is: ₹#(CM * targetUnitSelling  - FC). 
In this case, the initial investment is expected to be recovered by :
$ (₹investment)/(₹#CM"/unit" * (#targetUnitSelling "units" -#BEP_u "units")) approx #inv-payback-time "months" $

== Net Profit Margin
Once the investment has been recovered, the monthly profit at 30 units is:

$ "Net profit" = (₹#CM times #targetUnitSelling  - ₹#FC) = ₹#profit-per-month$

$"Monthly revenue" = ₹#SP times #targetUnitSelling = ₹#(SP * targetUnitSelling)$

$
"Net profit margin" = "Net profit"/"Net Montly revenue" = (₹#profit-per-month)/(₹#(SP * targetUnitSelling)) times 100%= bold(#(calc.round(profit-margin * 100 * 100)/100)%)
$
The figures above depend on selling 30 units a month. If volume is lower, the margin falls but the business remains viable above 10 units. For example, at 20 units a month the
contribution is ₹72,220 against fixed costs of ₹34,000, leaving about ₹38,220 a month. At 10 units the business only breaks even. This shows that the plan has a reasonable cushion: sales could fall by two-thirds from the target before the business starts making a loss.

= Reinvestment Plan
Rent is the largest recurring fixed cost. The founders already own land, so the plan
includes constructing a dedicated workshop on it instead of continuing to rent. The
estimated construction cost is ₹4.65 lakh, excluding land.
From the monthly profit of ₹74,330, this amount can be funded from earnings in about six
months (₹4,65,000 ÷ ₹74,330 ≈ 6.3 months). Once the building is complete, the ₹20,000
monthly rent is removed from the fixed costs. The monthly fixed cost would fall to
₹14,000, which lowers the break-even volume to about four units a month and raises the
monthly profit at 30 units to ₹94,330.
= Project Schedule and Critical Path
== Activities 
The path from project start to first shipment has been planned as a set of activities, with the time required for each given below.

#figure(
  caption: [Project Activities and Duration],
  table(
    columns: (1fr, 4fr, 1.5fr),
    align: (center, left, left),
    stroke: 0.5pt + luma(150),
    fill: (x, y) => if y == 0 { luma(240) } else { none },
    [*Activity*], [*Description*], [*Duration*],
    [A], [Clearance (licences and statutory approvals)], [4 weeks],
    [B], [Paperwork], [1 week],
    [C], [Components and equipment order], [2 weeks],
    [D], [PCB order], [3 weeks],
    [E], [Enclosure order], [2 weeks],
    [F], [PCB assembly and firmware flashing], [1 day],
    [G], [Final assembly and testing], [1 day],
    [H], [Packaging and shipping], [1 day]
  )
)

== CPM diagram

#align(center)[
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
    
    node((0, 0), [Start], shape: fletcher.shapes.ellipse, name: <O>),
    node((rel: (2.1cm, 1.8cm), to: <O>), [B: Paper work \ 1 weeks], name: <B>),
    node((rel: (2.4cm, .5cm), to: <O>), [C: Components \ & Equipments Order \ 2 weeks], name: <C>),
    node((rel: (2.07cm, -.75cm), to: <O>), [D: PCB Order\ 3 week], name: <D>),
    node((rel: (2.3cm, -1.8cm), to: <O>), [E: Enclosure Order\ 2 week], name: <E>),

    cnode((rel: (2cm, 3cm), to: <O>), [A: Clearance \ 4 weeks], name: <A>),
    cnode((rel: (2.6cm, 0cm), to: <A>), [F: PCB Assembly \ & FW flashing \ 1 day],name: <F>),
    cnode((rel: (2.5cm, 0cm)), [G: Final Assembly \ & testing 1 day], name: <G>),
    cnode((rel: (2.2cm, 0cm)), [H: Packaging \ & Shipping \ 1 day], name: <H>),
    
    edge(<B>, (<B.east>, "-|", <F.north>), <F>, "-|>"),
    edge(<F>, <G>, "-|>", stroke: cpm_s),
    edge(<G>, <H>, "-|>", stroke: cpm_s),
    
    bent-edge(<O.east>, <A.west>, stroke: cpm_s),
    bent-edge(<O.east>, <E.west>),
    bent-edge(<O.east>, <C.west>),
    bent-edge(<O.east>, <D.west>),
    bent-edge(<O.east>, <B.west>),
    edge(<A.east>, (<A.east>, "-|", <F.north>), <F.north>, "-|>", stroke: cpm_s),
    edge(<E.east>, (<E.east>, "-|", <G.south>), <G.south>, "-|>"),
    edge(<C.east>, (<C.east>, "-|", <F.north>), <F.south>, "-|>"),
    edge(<D.east>, (<D.east>, "-|", <F.north>), <F.south>, "-|>"),
    
  );
}]

The critical path is $A arrow F arrow G arrow H$. Clearance takes four weeks (28 days), and the three
production activities that follow take one day each, giving a total project duration of 31 days.

The ordering activities (components, PCB and enclosure) run in parallel with the clearance process, so they do not add to the total time as long as they are placed promptly. The PCB order, at three weeks, is the longest of these, and it has the least slack. If the PCB order is delayed by more than a week, it would start to delay the whole project. The paperwork and the PCB order should therefore be started on the first day.

= Risks and Mitigation
== Component supply and price. 
Prices of electronic components can change, and a particular part may go out of stock. The mitigation is to use common parts with known alternatives, to buy from established distributors, and to hold the 5 percent variable cost allowance.
== Import lead time. 
Bulk PCB orders from overseas take about three weeks. Placing the order early and keeping a small stock of boards after the first batch reduces the effect of delays.
== Competition. 
Similar products exist in the ₹8,000 to ₹10,000 range. The low unit cost provides room to reduce the price if required, and local presence and after-sales support are advantages over imported alternatives.

= Conclusion
PackCheck addresses a real and growing problem. Electric vehicle batteries are the costliest component of the vehicle, and the people who service them lack an affordable way of seeing inside the pack. By offering cell-level measurement, weak-cell identification, State of Health and internal resistance estimates, balancing and charging in one handheld unit, the product allows small shops to repair batteries that they would otherwise have to write off.
The project is technically feasible, since it uses standard components and established design techniques. It is financially sound: a unit cost of ₹4,389 and a selling price of ₹8,000 give a contribution of ₹3,611 per unit, break-even at ten units a month, and a payback period of about four months on an initial investment of ₹3,02,670. At 30 units a month, the net profit margin is nearly 31 percent. The planned reinvestment in an owned workshop would further reduce fixed costs. With a critical path of 31 days, driven by regulatory clearance, the product can reach the market within about a month of starting.
The demand will keep rising as the large number of EVs sold in recent years move out of warranty. A product that helps shops repair rather than replace has value for the customer, for the garage and for the wider goal of getting more use out of the batteries already in circulation

