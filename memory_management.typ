#import "setup.typ": *

#show: catpuccin-template.with(dark-mode: false)

// Title slide
#title-slide()

// Chapters
#include "chapters/01-introduction/introduction.typ"
#include "chapters/02-garbage-collection/garbage-collection.typ"
#include "chapters/03-reference-counting/reference-counting.typ"
#include "chapters/04-comparison/comparison.typ"
#include "chapters/05-type-system-approaches/type-system-approaches.typ"
#include "chapters/06-synthesis/synthesis.typ"
