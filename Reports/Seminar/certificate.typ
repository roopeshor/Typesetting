#import "settings.typ": addToPDFBookmark, fontsizes, report-title
#set page(margin: 1.2in)
#place(center + horizon)[
  #text(size: fontsizes.heading2)[
    DIVISION OF ELECTRONICS ENGINEERING\
    SCHOOL OF ENGINEERING \
    COCHIN UNIVERSITY OF SCIENCE AND
    TECHNOLOGY \
    KOCHI-682022
  ]

  #v(10pt)

  #image("images/cusat.svg", width: 4cm)
  
	#v(10pt)
  
	#text(size: fontsizes.heading2)[*CERTIFICATE*]
  
	#addToPDFBookmark("Certificate")
  
	#v(10pt)

  #par(justify: true, leading: 1em)[
    #text(
      size: fontsizes.body,
			style: "italic"
    )[Certified that the seminar report entitled *“#report-title”* is a bonafide work of #h(2pt) *Roopesh O R* #h(2pt) towards the partial fulfillment for the award of the degree of B.Tech in Electronics and Communication of Cochin University of Science and Technology, Kochi-682022.]
  ]

  #v(3.5cm)

  #place(left)[#text(size: 12pt)[*Staff-in-charge*]]
  #place(right)[#text(size: 12pt)[*Head of the Division*]]
]

#pagebreak()
