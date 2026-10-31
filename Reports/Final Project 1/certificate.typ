#import "settings.typ": addToPDFBookmark
#set page(margin: 1.2in)
#align(center + horizon)[
  #text(size: 15pt)[
    DIVISION OF ELECTRONICS ENGINEERING\
    SCHOOL OF ENGINEERING\
    COCHIN UNIVERSITY OF SCIENCE AND\
    TECHNOLOGY\
    KOCHI-682022
  ]

  #v(10pt)
  #image("images/cusat.svg", width: 4cm)
  #v(10pt)
  #text(size: 15pt)[*CERTIFICATE*]
  #addToPDFBookmark("Certificate")
  #v(10pt)
]
  #par(justify: true, leading: 1em)[
    #text(
      size: 12pt,
			style: "italic"
    )[Certified that the project report entitled *“Analysis and Verification of Wind Profile Estimation Algorithms”* is a bonafide work of #h(2pt)#text(weight: "bold")[Naveen C Lal (20323079), Roopesh O R (20323085), Sneha S (20323094)]#h(2pt) towards the partial fulfilment of the award of the degree of B.Tech in Electronics and Communication of Cochin University of Science and Technology, Kochi-682022.]
  ]

  #v(3.5cm)
  #place(left)[#text(size: 12pt)[*Project Guide*]]
  #place(right)[#text(size: 12pt)[*Head of the Division*]]
#pagebreak()