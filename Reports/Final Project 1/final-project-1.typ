#import "settings.typ": *
#show: settings

#outline(target: heading, depth:3, title: [List of Contents])
#outline(target: figure, title: [List of Figures])

#include "intro.typ"
#include "methods.typ"
#include "synthetic generation.typ"

#bibliography("bib.yaml", title: [References])