#import "settings.typ": addToPDFBookmark, author, regNo, report-title, submitted-to

#set text(size: 13.5pt)
#set par(spacing: .9em)
#place(center + horizon)[
  #addToPDFBookmark("Cover")
  #text(size: 15pt)[*ADVANCED SYSTEMS LABORATORY*]

  #text(size: 15pt)[*DEFENCE RESEARCH AND DEVELOPMENT ORGANISATION*]

  #image("images/drdo.svg", width: 4.5cm)

  #text(size: 18pt)[*INTERNSHIP REPORT*]

  _On_

  #text(size: 18pt)[*#report-title*]


  #v(13pt)
  _Submitted by_
  #v(10pt)
  #text(weight: "bold")[#upper[#author] (#regNo)]

  #v(13pt)
  _Submitted in partial fulfillment of the requirements for the\
  B.Tech in Electronics and Communication Engineering_\

  #v(13pt)

  *Under the Guidance of*\
  #submitted-to
  #v(10pt)

  *Internship Duration:*\
  May 18 2026 - June 15 2026 \


  #v(30pt)
  *DIVISION OF ELECTRONICS ENGINEERING*\
  *SCHOOL OF ENGINEERING*\
  *COCHIN UNIVERSITY OF SCIENCE AND TECHNOLOGY*\
  *KOCHI - 682022*\

  #v(13pt)

  *July 2026*
]
#pagebreak()
