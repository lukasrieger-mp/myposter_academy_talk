#import "../../setup.typ": *

= Wrapping Up

== Lesser-known approaches

#align(center)[#cetz.canvas(length: 1.35cm, {
  import cetz.draw: *

  let colors = (rgb("#8839ef"), rgb("#40a02b"), rgb("#1e66f5"), rgb("#fe640b"), rgb("#dc8a78"), rgb("#d20f39"), rgb("#9ca0b0"))

  let box(x, y, w, label, sublabel, col) = {
    rect((x - w/2, y - 0.55), (x + w/2, y + 0.55), fill: col.lighten(80%), stroke: col + 1.5pt, radius: 4pt)
    content((x, y + 0.15), text(size: 10pt, weight: "bold", fill: col.darken(20%))[#label])
    content((x, y - 0.25), text(size: 8pt, fill: rgb("#6c6f85"))[#sublabel])
  }

  box(1.5, 4.2, 3.2, "Regions", "Pony, Verona", colors.at(2))
  box(5.5, 5, 3.5, "Arenas", "Zig, Odin, Ada", colors.at(3))
  box(10.5, 4.5, 4.2, "Generational References", "Vale", colors.at(4))
  box(3.5, 2.2, 4, "Constraint References", "Game engines", colors.at(5))
  box(8.5, 2.5, 3.5, "Hardware Safety", "CHERI", colors.at(6))
  box(13, 1.5, 3.5, "Interaction Nets", "HVM", colors.at(0))
  box(0.5, 0.5, 2.5, "Neverfree", "Missiles(!)", colors.at(6))
  box(5.5, 0.2, 3.5, "Stack Arenas", "Basil", colors.at(3))
  box(10.5, 0.2, 4, "Linear Reference Counting", "(theoretical)", colors.at(2))
})]

#text(size: 0.8em)[#furtherreading[The Memory Safety Grimoire @grimoire catalogs *17+ distinct approaches*. The design space is far from settled.]]

== Key takeaways

+ *Memory management is a design decision*, shaped by platform constraints

+ *Tracing GC:* throughput with short-lived objects, needs heap headroom

+ *Reference counting:* deterministic cleanup, low overhead, but cycles and per-write cost

+ *Ownership:* compile-time safety, zero runtime cost, steeper learning curve

+ GC and RC *converge* as both are optimized

#v(1em)
#align(center)[*Thank you! Questions?*]

== References

#set text(size: 0.7em)
#bibliography("/references.bib", style: "ieee", title: none)
