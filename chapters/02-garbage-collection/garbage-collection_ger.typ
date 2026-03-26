#import "../../setup.typ": *

= Garbage Collection

== Tracing Garbage Collection

*Kernidee:* die Runtime ermittelt, was tot ist.

- Collector gibt Objekte frei *gdw.* kein erreichbarer Pointer existiert
- Nur der Collector gibt frei: keine Double-Frees, keine Dangling Pointer

```java
void process() {
    var list = new ArrayList<>();
    list.add(compute());
    // no free() needed -- GC reclaims when unreachable
}
```

== Mark-and-Sweep

#slide(composer: (1fr, 1fr))[
  Grundlegender GC-Algorithmus @mccarthy1960:

  === Mark-Phase
  Von *Roots* (Stack, Globals) ausgehend alle erreichbaren Objekte markieren.

  === Sweep-Phase
  Gesamten Heap durchlaufen, alles *Unmarkierte* freigeben.
][
  #align(center + horizon)[#cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let live = rgb("#40a02b")
    let dead = rgb("#d20f39")
    let root-c = rgb("#8839ef")

    rect((-0.6, 5.5), (0.6, 6.3), fill: root-c.lighten(70%), stroke: root-c + 1pt, radius: 3pt)
    content((0, 5.9), text(size: 8pt, weight: "bold")[Roots])

    circle((0, 4), radius: 0.55, fill: live.lighten(70%), stroke: live + 1.5pt)
    content((0, 4), text(size: 8pt, weight: "bold")[A])
    circle((-1.8, 2.3), radius: 0.55, fill: live.lighten(70%), stroke: live + 1.5pt)
    content((-1.8, 2.3), text(size: 8pt, weight: "bold")[B])
    circle((1.8, 2.3), radius: 0.55, fill: live.lighten(70%), stroke: live + 1.5pt)
    content((1.8, 2.3), text(size: 8pt, weight: "bold")[C])

    circle((4, 4), radius: 0.55, fill: dead.lighten(80%), stroke: dead + 1pt)
    content((4, 4), text(size: 8pt, fill: dead)[D])
    circle((4, 2.3), radius: 0.55, fill: dead.lighten(80%), stroke: dead + 1pt)
    content((4, 2.3), text(size: 8pt, fill: dead)[E])

    line((0, 5.5), (0, 4.55), mark: (end: ">", fill: root-c), stroke: root-c + 1pt)
    line((-0.4, 3.5), (-1.4, 2.8), mark: (end: ">", fill: live), stroke: live + 1pt)
    line((0.4, 3.5), (1.4, 2.8), mark: (end: ">", fill: live), stroke: live + 1pt)

    content((0, 1.2), text(size: 7pt, fill: live)[#sym.checkmark markiert (live)])
    content((4, 1.2), text(size: 7pt, fill: dead)[#sym.times aufgeräumt (Garbage)])
  })]
]

== Die Tricolour-Abstraktion

Zentrale Abstraktion für Tracing Collectors (warum der Android-Profiler "Concurrent GC" zeigt):

- *White*: noch nicht besucht (vermutlich Garbage)
- *Grey*: besucht, Kinder noch nicht gescannt
- *Black*: besucht, alle Kinder gescannt

#align(center)[#cetz.canvas(length: 0.85cm, {
  import cetz.draw: *

  let white-c = rgb("#ccd0da")
  let grey-c = rgb("#9ca0b0")
  let black-c = rgb("#4c4f69")

  circle((0, 0), radius: 0.55, fill: black-c, stroke: black-c + 1.5pt)
  content((0, 0), text(size: 7pt, fill: white, weight: "bold")[R])
  circle((2.2, 0), radius: 0.55, fill: black-c, stroke: black-c + 1.5pt)
  content((2.2, 0), text(size: 7pt, fill: white, weight: "bold")[A])

  circle((4.5, 0.9), radius: 0.55, fill: grey-c, stroke: grey-c + 1.5pt)
  content((4.5, 0.9), text(size: 7pt, fill: white, weight: "bold")[B])
  circle((4.5, -0.9), radius: 0.55, fill: grey-c, stroke: grey-c + 1.5pt)
  content((4.5, -0.9), text(size: 7pt, fill: white, weight: "bold")[C])

  circle((7, 0.9), radius: 0.55, fill: white-c.lighten(50%), stroke: white-c + 1.5pt)
  content((7, 0.9), text(size: 7pt)[D])
  circle((7, -0.9), radius: 0.55, fill: white-c.lighten(50%), stroke: white-c + 1.5pt)
  content((7, -0.9), text(size: 7pt)[E])

  line((0.55, 0), (1.65, 0), mark: (end: ">", fill: black-c), stroke: 1pt)
  line((2.65, 0.3), (3.95, 0.7), mark: (end: ">", fill: black-c), stroke: 1pt)
  line((2.65, -0.3), (3.95, -0.7), mark: (end: ">", fill: black-c), stroke: 1pt)
  line((5.05, 0.9), (6.45, 0.9), mark: (end: ">", fill: grey-c), stroke: 1pt)
  line((5.05, -0.9), (6.45, -0.9), mark: (end: ">", fill: grey-c), stroke: 1pt)

  circle((1.5, -2.4), radius: 0.35, fill: black-c, stroke: black-c + 1pt)
  content((2.8, -2.4), text(size: 7pt)[Black (fertig)])
  circle((4.5, -2.4), radius: 0.35, fill: grey-c, stroke: grey-c + 1pt)
  content((5.7, -2.4), text(size: 7pt)[Grey (ausstehend)])
  circle((7.5, -2.4), radius: 0.35, fill: white-c.lighten(50%), stroke: white-c + 1pt)
  content((8.9, -2.4), text(size: 7pt)[White (ungesehen)])
})]

== Die meisten Objekte sterben jung

*Weak Generational Hypothesis:*

#text(size: 0.9em)[#table(
  columns: (auto, auto, auto),
  inset: 6pt,
  align: (left, left, left),
  table.header([*Sprache*], [*Ergebnis*], [*Quelle*]),
  [Lisp], [98% pro Collection zurückgewonnen], [Foderaro & Fateman, 1981],
  [Java], [#sym.lt 9% überleben 4 MB Nursery], [Blackburn et al, 2006],
  [Smalltalk], [#sym.lt 7% überleben 140 KB], [Ungar, 1986],
)]

Grundlage der *Generational Garbage Collection*.

#misconception[_"GC ist langsam."_ GC besucht tote Objekte nie einzeln. Nursery wird *in einem Rutsch* freigegeben. Kosten proportional zu *Überlebenden*, nicht Garbage.]

== Warum Bulk Reclaim schnell ist

#align(center)[#cetz.canvas(length: 1.1cm, {
  import cetz.draw: *

  let live-c = rgb("#40a02b")
  let dead-c = rgb("#ccd0da")
  let free-c = rgb("#eff1f5")
  let border-c = rgb("#9ca0b0")
  let accent = rgb("#8839ef")

  content((5, 7.5), text(size: 14pt, weight: "bold")[Vor der Collection])

  rect((0, 1), (10, 5.5), stroke: border-c + 1.5pt, radius: 4pt)
  content((5, 6), text(size: 11pt, weight: "bold")[Nursery])

  rect((0.4, 3.5), (1.4, 4.8), fill: dead-c, stroke: border-c, radius: 2pt)
  rect((1.7, 3.5), (2.7, 4.8), fill: dead-c, stroke: border-c, radius: 2pt)
  rect((3.0, 3.5), (4.0, 4.8), fill: live-c.lighten(50%), stroke: live-c + 1.5pt, radius: 2pt)
  content((3.5, 4.15), text(size: 8pt, fill: live-c, weight: "bold")[live])
  rect((4.3, 3.5), (5.3, 4.8), fill: dead-c, stroke: border-c, radius: 2pt)
  rect((5.6, 3.5), (6.6, 4.8), fill: dead-c, stroke: border-c, radius: 2pt)
  rect((6.9, 3.5), (7.9, 4.8), fill: dead-c, stroke: border-c, radius: 2pt)
  rect((8.2, 3.5), (9.2, 4.8), fill: live-c.lighten(50%), stroke: live-c + 1.5pt, radius: 2pt)
  content((8.7, 4.15), text(size: 8pt, fill: live-c, weight: "bold")[live])

  rect((0.4, 1.7), (1.4, 3.0), fill: dead-c, stroke: border-c, radius: 2pt)
  rect((1.7, 1.7), (2.7, 3.0), fill: dead-c, stroke: border-c, radius: 2pt)
  rect((3.0, 1.7), (4.0, 3.0), fill: dead-c, stroke: border-c, radius: 2pt)

  line((9.5, 1), (9.5, 5.5), stroke: accent + 2pt)
  content((9.5, 0.3), text(size: 10pt, fill: accent)[Bump Ptr])

  content((5, -0.4), text(size: 11pt)[9 tot, 2 lebendig. GC *berührt tote nie*.])

  line((11, 3.25), (12.5, 3.25), mark: (end: ">", fill: accent), stroke: accent + 2.5pt)

  content((18.5, 7.5), text(size: 14pt, weight: "bold")[Nach der Collection])

  rect((21, 5.8), (22, 7.1), fill: live-c.lighten(50%), stroke: live-c + 1.5pt, radius: 2pt)
  rect((22.3, 5.8), (23.3, 7.1), fill: live-c.lighten(50%), stroke: live-c + 1.5pt, radius: 2pt)
  content((22.15, 7.6), text(size: 9pt, fill: live-c)[promoted])

  rect((13.5, 1), (23.5, 5.5), stroke: border-c + 1.5pt, fill: free-c, radius: 4pt)
  content((18.5, 6), text(size: 11pt, weight: "bold")[Nursery (reset)])

  content((18.5, 3.25), text(size: 14pt, fill: border-c, weight: "bold")[gesamter Speicher frei])

  line((13.8, 1), (13.8, 5.5), stroke: accent + 2pt)
  content((13.8, 0.3), text(size: 10pt, fill: accent)[Bump Ptr])

  content((18.5, -0.4), text(size: 11pt)[Nursery frei. Bump Ptr zurück. *Null Pro-Objekt-Kosten.*])
})]

== Generational GC

#slide(composer: (1fr, 1fr))[
  - Objekte nach Alter in *Generationen* aufgeteilt
  - *Young Gen (Nursery):* häufig gesammelt, sehr günstig
  - *Old Gen:* selten gesammelt, teurer
  - Überlebende werden in Old Gen *promoted*
  - Young-Gen-Pausen deutlich kürzer als Full-Heap-Collections
][
  #align(center + horizon)[#cetz.canvas(length: 0.9cm, {
    import cetz.draw: *

    let young-c = rgb("#40a02b")
    let old-c = rgb("#1e66f5")
    let arrow-c = rgb("#8839ef")

    rect((0, 2), (4.5, 5.5), fill: young-c.lighten(80%), stroke: young-c + 1.5pt, radius: 4pt)
    content((2.25, 4.8), text(size: 9pt, weight: "bold", fill: young-c.darken(20%))[Young Gen])
    content((2.25, 4.1), text(size: 7pt, fill: young-c.darken(10%))[(Nursery)])

    circle((0.9, 2.9), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))
    circle((1.7, 2.9), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))
    circle((2.5, 2.9), radius: 0.3, fill: young-c.lighten(40%), stroke: young-c)
    circle((3.3, 2.9), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))

    rect((6, 2), (10.5, 5.5), fill: old-c.lighten(85%), stroke: old-c + 1.5pt, radius: 4pt)
    content((8.25, 4.8), text(size: 9pt, weight: "bold", fill: old-c.darken(20%))[Old Gen])

    circle((7.2, 3.2), radius: 0.4, fill: old-c.lighten(50%), stroke: old-c)
    circle((8.3, 3.2), radius: 0.4, fill: old-c.lighten(50%), stroke: old-c)
    circle((9.4, 3.2), radius: 0.4, fill: old-c.lighten(50%), stroke: old-c)

    line((4.5, 3.75), (6.0, 3.75), mark: (end: ">", fill: arrow-c), stroke: arrow-c + 1.5pt)
    content((5.25, 4.5), text(size: 7pt, fill: arrow-c)[Promotion])

    content((2.25, 1.3), text(size: 7pt, fill: rgb("#888"))[häufig gesammelt])
    content((8.25, 1.3), text(size: 7pt, fill: rgb("#888"))[selten gesammelt])
  })]
]

== Bulk Reclaim und Heap Headroom

#slide(composer: (1fr, 1fr))[
  === Superkraft des GC

  Wenn die meisten Objekte jung sterben:

  - Tausende Objekte werden zwischen Collections zu Garbage
  - Nursery wird *in einem Rutsch* freigegeben
  - Kosten skalieren mit *Überlebenden*, nicht Garbage

  #alert[Weniger Überlebende = günstigere Collection.]
][
  === Der Preis

  GC braucht Spielraum:

  - `malloc`/`free`-Performance erst bei *5× Min-Heap* @hertz2005
  - Typisch: #sym.tilde 17% Durchsatz-Overhead @hertz2005
  - Typische Config: *1,3--4× Min-Heap* @jones2012

  Auf *speicherbeschränkten Geräten*: Headroom ist Luxus.
]

== GC auf Android

ART nutzt Tracing GC mit nebenläufigen Collectoren:

- *Concurrent Copying* (generational, Standard)
- *Concurrent Mark-Compact* (neuer, weniger Fragmentierung)
- Untere Schranke GC-Overhead: *2--51%* @sareen2024

Mobile-Herausforderungen:
- 16 ms Frame-Budget bei 60 Hz (weniger bei 90/120 Hz): GC-Pause = Ruckeln
- Gerätespezifische Heap-Limits pro App
- Bei Speicherdruck: Android *killt* Hintergrund-Apps @lebeck2020
