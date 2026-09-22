#import "@preview/touying:0.7.4": *
#import "@preview/cetz:0.5.2"
#import "@preview/numbly:0.1.0": numbly

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set par(leading: 1em)
    set align(horizon)
    set text(
      fill: self.colors.neutral-lightest,
      size: .7em,
      font: "Poppins",
    )
    context {
      if (utils.current-heading(level: 2) != none) and (utils.current-heading(level: 2).body != [Outline]) {
        grid(
          columns: 2,
          utils.display-current-heading(level: 1),
          align: top,
          column-gutter: .3em,
          text(size: .8em)[$triangle.filled.r$],
        )
        v(-1.1em)
      } else {
        text(size: 2em)[#utils.display-current-heading(level: 1)]
      }
    }

    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      text(size: 1.9em)[#utils.display-current-heading(level: 2)]
    }
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context text(size: .8em, font: "Poppins", weight: "semibold", fill: self.colors.primary)[
      #utils.slide-counter.display()//\/#utils.last-slide-number
    ]
  }

  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  self = utils.merge-dicts(
    self,
    config-page(margin: 0em),
  )
  let body = {
    set align(center + horizon)
    grid(
      columns: (1fr, 2fr),
      block(width: 100%, height: 100%)[
        #place(horizon + right)[
          #line(length: 100%, angle: 90deg, stroke: 1.5pt + self.colors.secondary)
        ]
        #image("images/drdo.svg", width: 75%)
      ],
      [
        #block(inset: 1cm)[
          #text(
            size: 1.4em,
            fill: self.colors.primary-darkest,
            weight: "semibold",
            font: "Poppins",
            info.title,
          )
          #v(-15pt)
          #text(size: .9em, weight: "light")[on]\
          #v(-5pt)
          #text(
            size: 1.1em,
            fill: self.colors.primary-darkest,
            weight: "semibold",
            font: "Poppins",
            info.subtitle,
          )\
          #text(size: .9em, weight: "light")[by]\
          #v(-5pt)
          #block(info.author)
          #v(15pt)
          #text(size: .9em, weight: "light")[Internship carried out at]\
          #v(-5pt)
          #text(
            size: 1em,
            fill: self.colors.primary-darkest,
            weight: "semibold",
            font: "Poppins",
            info.subtitle2,
          )
          #v(15pt)
					#scale(90%)[
          // #text(size: .9em)[_Under the guidance of_]\
          // #v(-5pt)
          // #text(
          //   size: 1em,
          //   fill: self.colors.primary-darkest,
          //   weight: "semibold",
          //   font: "Poppins",
          //   info.subtitle3,
          // )
          // #v(15pt)
          Duration:
					
          #text(
            size: 1em,
            fill: self.colors.primary-darkest,
            weight: "semibold",
            font: "Poppins",
            info.subtitle4,
          )]
        ]
      ],
    )
  }
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(margin: (top: 0em)),
  )
  let main-body = {
    set align(center + horizon)
    set text(font: "Poppins", size: 2em, fill: self.colors.primary, weight: "semibold")
    v(-1cm)
    utils.display-current-heading(level: 1)
  }
  touying-slide(self: self, main-body)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 0em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  touying-slide(self: self, align(horizon + center, body))
})

#let my-theme(
  aspect-ratio: "16-9",
  footer: none,
  ..args,
  body,
) = {
  set text(size: 20pt)
	let pc = args.color-primary;
	let sc = args.color-primary.darken(10%);
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 5.5em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(alert: utils.alert-with-primary-color),
    config-colors(
      primary: pc,
      secondary: sc,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-store(
      title: none,
      footer: footer,
    ),
    ..args,
  )
  show outline.entry: set text(size: .9em)
  show outline.entry.where(level: 1): set block(above: 20pt)
  show outline.entry.where(level: 1): set text(weight: "semibold", fill: args.color-primary)
  show figure.caption: set text(size: .8em, style: "italic")
  set text(font: "Arial", size: 18pt)
  show math.equation: set text(size: 1.2em)
  show list: set par(
    leading: 0.7em,
    spacing: 1em,
  )
  set heading(numbering: numbly("{1}.", default: "1.1"))

  body
}
