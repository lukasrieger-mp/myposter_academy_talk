#import "setup.typ": *
#import "@preview/metropolyst:0.1.0": config-info

#show: catpuccin-template.with(dark-mode: false)

// Override title for German version
#set text(lang: "de")

// Title slide
#title-slide()

// Chapters (German)
#include "chapters/01-introduction/introduction_ger.typ"
#include "chapters/02-garbage-collection/garbage-collection_ger.typ"
#include "chapters/03-reference-counting/reference-counting_ger.typ"
#include "chapters/04-comparison/comparison_ger.typ"
#include "chapters/05-type-system-approaches/type-system-approaches_ger.typ"
#include "chapters/06-synthesis/synthesis_ger.typ"
