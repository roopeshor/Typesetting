#import "settings.typ": addToPDFBookmark, author, regNo, report-title, submitted-to

#set text(size: 13.5pt)
#set par(spacing: .9em)
#set page(margin: 1.5in)
#place(center + horizon)[
  #addToPDFBookmark("Cover")
  #text(size: 16pt)[*INTERNSHIP-III REPORT*]

  _On_

  #text(size: 18pt)[*#report-title*]

  #v(10pt)
  _Submitted by_
  
  #text(weight: "bold")[#upper[#author] (#regNo)]

  #v(23pt)
  
  _in partial fulfillment of the requirements for the award of the degree of B.Tech in Electronics and Communication Engineering_
  #v(20pt)
  #image("images/cusat.svg", width: 4.5cm)
  #v(20pt)
  #text[
    _Internship carried out at_
    
    *Advanced System Laboratory - DRDO, Hyderabad*
    
    #v(10pt)
    _Under the Guidance of_
    
    *#submitted-to*
    #v(10pt)

    _Internship Duration:_
    
    *May 18 2026 - July 15 2026* 
  ]
  #v(30pt)
  *DIVISION OF ELECTRONICS ENGINEERING*\
  *SCHOOL OF ENGINEERING*\
  *COCHIN UNIVERSITY OF SCIENCE AND TECHNOLOGY*\
  *KOCHI - 682022*\

  #v(13pt)

  *July 2026*
]
#pagebreak()
