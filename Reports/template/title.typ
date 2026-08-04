#import "settings.typ": addToPDFBookmark, fontsizes, report-title

#set text(size: 13.5pt)
#set par(spacing: .9em)
#place(center + horizon)[
  #addToPDFBookmark("Cover")
  #text(size: 14pt)[*SEMINAR REPORT*]
  #v(13pt)

on
  #v(13pt)
  
  #text(size: 18pt)[#text(weight: "bold")[#report-title]]

  #v(13pt)
  
	_Submitted by_
  
	#v(10pt)
  
	#text(size: 14.5pt)[*Author*]

  #v(13pt)
  
	_Submitted in partial fulfillment of the requirements for the award \ of\ _

  #v(13pt)

  #text(size: 14pt)[*BACHELOR OF TECHNOLOGY 
\ in \ ELECTRONICS AND COMMUNICATION*]

  #v(20pt)

	#image("images/cusat.svg", width: 4cm)

  #v(25pt)
  *DIVISION OF ELECTRONICS ENGINEERING*\
  *SCHOOL OF ENGINEERING*\
  *COCHIN UNIVERSITY OF SCIENCE AND TECHNOLOGY*\
  *KOCHI - 682022*\

  #v(13pt)

  *July 2026*
]
#pagebreak()
