#import "../../setup.typ": *

= Tracing Garbage Collection

== The mutator and the collector

#align(center)[#cetz.canvas(length: 1.1cm, {
  import cetz.draw: *

  let mutator-c = rgb("#1e66f5")
  let collector-c = rgb("#40a02b")
  let heap-c = rgb("#8839ef")
  let border-c = rgb("#9ca0b0")

  // Mutator box (left)
  rect((0, 0.5), (4.5, 5), fill: mutator-c.lighten(85%), stroke: mutator-c + 1.5pt, radius: 5pt)
  content((2.25, 4.3), text(size: 13pt, weight: "bold", fill: mutator-c.darken(10%))[Mutator])
  content((2.25, 3.5), text(size: 10pt, fill: rgb("#6c6f85"))[your program])
  content((2.25, 2.5), text(size: 9pt, fill: rgb("#6c6f85"))[allocates objects])
  content((2.25, 1.8), text(size: 9pt, fill: rgb("#6c6f85"))[creates/removes refs])
  content((2.25, 1.1), text(size: 9pt, fill: rgb("#6c6f85"))[never calls `free`])

  // Heap (center)
  rect((6, 0), (12, 5.5), fill: heap-c.lighten(90%), stroke: heap-c + 2pt, radius: 5pt)
  content((9, 4.7), text(size: 13pt, weight: "bold", fill: heap-c.darken(10%))[Heap])

  // Objects in heap
  circle((7.3, 3.2), radius: 0.4, fill: collector-c.lighten(60%), stroke: collector-c)
  circle((8.5, 3.5), radius: 0.4, fill: collector-c.lighten(60%), stroke: collector-c)
  circle((9.8, 3.0), radius: 0.4, fill: border-c.lighten(40%), stroke: border-c)
  circle((10.8, 3.6), radius: 0.4, fill: border-c.lighten(40%), stroke: border-c)
  circle((7.8, 1.5), radius: 0.4, fill: collector-c.lighten(60%), stroke: collector-c)
  circle((9.2, 1.8), radius: 0.4, fill: border-c.lighten(40%), stroke: border-c)
  circle((10.5, 1.3), radius: 0.4, fill: border-c.lighten(40%), stroke: border-c)

  // Arrows: objects connected
  line((7.7, 3.2), (8.1, 3.4), mark: (end: ">", fill: rgb("#838ba7")), stroke: rgb("#838ba7") + 0.8pt)
  line((8.9, 3.4), (9.4, 3.1), mark: (end: ">", fill: rgb("#838ba7")), stroke: rgb("#838ba7") + 0.8pt)
  line((7.5, 2.8), (7.7, 1.9), mark: (end: ">", fill: rgb("#838ba7")), stroke: rgb("#838ba7") + 0.8pt)

  // Collector box (right)
  rect((13.5, 0.5), (18, 5), fill: collector-c.lighten(85%), stroke: collector-c + 1.5pt, radius: 5pt)
  content((15.75, 4.3), text(size: 13pt, weight: "bold", fill: collector-c.darken(10%))[Collector])
  content((15.75, 3.5), text(size: 10pt, fill: rgb("#6c6f85"))[garbage collector])
  content((15.75, 2.5), text(size: 9pt, fill: rgb("#6c6f85"))[scans for reachable])
  content((15.75, 1.8), text(size: 9pt, fill: rgb("#6c6f85"))[frees unreachable])
  content((15.75, 1.1), text(size: 9pt, fill: rgb("#6c6f85"))[decides what + when])

  // Arrows: mutator → heap
  line((4.5, 3.5), (6, 3.5), mark: (end: ">", fill: mutator-c), stroke: mutator-c + 1.5pt)
  content((5.25, 4.2), text(size: 8pt, fill: mutator-c)[allocate])

  // Arrows: collector → heap
  line((13.5, 2), (12, 2), mark: (end: ">", fill: collector-c), stroke: collector-c + 1.5pt)
  content((12.75, 1.3), text(size: 8pt, fill: collector-c)[reclaim])

  // Arrows: collector → heap (scan)
  line((13.5, 3.5), (12, 3.5), mark: (end: ">", fill: collector-c), stroke: (paint: collector-c, thickness: 1.5pt, dash: "dashed"))
  content((12.75, 4.2), text(size: 8pt, fill: collector-c)[scan])
})]

Two actors share the heap. The *mutator* (your program) allocates objects and manipulates references but never frees memory. A separate *collector* periodically identifies unreachable objects and reclaims their memory. The programmer writes normal code; the collector handles deallocation @jones2012.

== Mark-and-Sweep

#slide(composer: (1fr, 1fr))[
  Foundational tracing algorithm @mccarthy1960:

  === Mark phase
  Trace from *roots* (stack, globals), mark all reachable objects.

  === Sweep phase
  Walk entire heap, reclaim everything *unmarked*.

  Simple, correct, but requires *stopping the mutator* for the entire duration.
][
  #align(center + horizon)[#cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let live = rgb("#40a02b")
    let dead = rgb("#d20f39")
    let root-c = rgb("#8839ef")

    rect((-0.6, 5.5), (0.6, 6.3), fill: root-c.lighten(70%), stroke: root-c + 1pt, radius: 3pt)
    content((0, 5.9), text(size: 8pt, weight: "bold", fill: root-c.darken(30%))[Roots])

    circle((0, 4), radius: 0.55, fill: live.lighten(70%), stroke: live + 1.5pt)
    content((0, 4), text(size: 8pt, weight: "bold", fill: live.darken(30%))[A])
    circle((-1.8, 2.3), radius: 0.55, fill: live.lighten(70%), stroke: live + 1.5pt)
    content((-1.8, 2.3), text(size: 8pt, weight: "bold", fill: live.darken(30%))[B])
    circle((1.8, 2.3), radius: 0.55, fill: live.lighten(70%), stroke: live + 1.5pt)
    content((1.8, 2.3), text(size: 8pt, weight: "bold", fill: live.darken(30%))[C])

    circle((4, 4), radius: 0.55, fill: dead.lighten(80%), stroke: dead + 1pt)
    content((4, 4), text(size: 8pt, fill: dead.darken(20%))[D])
    circle((4, 2.3), radius: 0.55, fill: dead.lighten(80%), stroke: dead + 1pt)
    content((4, 2.3), text(size: 8pt, fill: dead.darken(20%))[E])

    line((0, 5.5), (0, 4.55), mark: (end: ">", fill: root-c), stroke: root-c + 1pt)
    line((-0.4, 3.5), (-1.4, 2.8), mark: (end: ">", fill: live), stroke: live + 1pt)
    line((0.4, 3.5), (1.4, 2.8), mark: (end: ">", fill: live), stroke: live + 1pt)

    content((0, 1.2), text(size: 7pt, fill: live)[#sym.checkmark marked (live)])
    content((4, 1.2), text(size: 7pt, fill: dead)[#sym.times swept (garbage)])
  })]
]

== Where pauses come from

Basic mark-and-sweep = *stop-the-world* (STW):

- Mutator halted for entire mark + sweep duration
- Pause proportional to *heap size*, not garbage
- Large heaps = long pauses = visible jank

This is why "GC is slow" became folklore. But modern collectors don't work this way.

== Parallel and concurrent collection

#slide(composer: (1fr, 1fr))[
  === Parallel collection

  - Multiple collector threads work *simultaneously*
  - Mutator still *stopped* during collection
  - Faster STW pauses (work split across cores)
  - Simpler: no mutator interference
][
  === Concurrent collection

  - Collector and mutator run *at the same time*
  - *Write barriers* track mutator changes during marking
  - Much shorter (or no) STW pauses
  - Trade-off: more CPU overhead, more complexity
]

== The tricolour invariant

#align(center)[#cetz.canvas(length: 0.88cm, {
  import cetz.draw: *

  let white-c = rgb("#ccd0da")
  let grey-c = rgb("#9ca0b0")
  let black-c = rgb("#4c4f69")
  let barrier-c = rgb("#d20f39")
  let r = 0.65
  let pw = 7  // panel width
  let gap = 2  // gap between panels

  // Helper to draw a panel
  let panel(ox, label, draw-fn) = {
    content((ox + pw/2, 7.2), text(size: 10pt, weight: "bold")[#label])
    rect((ox, -0.2), (ox + pw, 6.2), stroke: (paint: grey-c, thickness: 1pt, dash: "dashed"), radius: 5pt)
    draw-fn(ox)
  }

  // Positions: panel 1 at 0, panel 2 at pw+gap, panel 3 at 2*(pw+gap)
  let p1 = 0
  let p2 = pw + gap
  let p3 = 2 * (pw + gap)

  // === STEP 1: Before mutation ===
  panel(p1, "1. Before mutation", ox => {
    circle((ox + 1.2, 4.5), radius: r, fill: black-c, stroke: black-c + 1.5pt)
    content((ox + 1.2, 4.5), text(size: 10pt, fill: white, weight: "bold")[A])
    circle((ox + 3.8, 4.5), radius: r, fill: grey-c, stroke: grey-c + 1.5pt)
    content((ox + 3.8, 4.5), text(size: 10pt, fill: white, weight: "bold")[B])
    circle((ox + 5.8, 4.5), radius: r, fill: white-c.lighten(50%), stroke: white-c + 1.5pt)
    content((ox + 5.8, 4.5), text(size: 10pt, fill: black-c)[C])
    circle((ox + 2.5, 1.8), radius: r, fill: white-c.lighten(50%), stroke: white-c + 1.5pt)
    content((ox + 2.5, 1.8), text(size: 10pt, fill: black-c)[D])

    line((ox + 1.85, 4.5), (ox + 3.15, 4.5), mark: (end: ">", fill: black-c), stroke: black-c + 1.2pt)
    line((ox + 4.45, 4.5), (ox + 5.15, 4.5), mark: (end: ">", fill: grey-c), stroke: grey-c + 1.2pt)
    line((ox + 3.4, 3.9), (ox + 2.9, 2.4), stroke: (paint: grey-c, thickness: 1pt, dash: "dashed"), mark: (end: ">", fill: grey-c))
  })

  // Arrow between panels
  line((pw + 0.3, 3), (pw + gap - 0.3, 3), mark: (end: ">", fill: grey-c), stroke: grey-c + 2pt)

  // === STEP 2: Mutator writes A→D (barrier intercepts) ===
  panel(p2, "2. Mutator writes A" + sym.arrow + "D", ox => {
    circle((ox + 1.2, 4.5), radius: r, fill: black-c, stroke: black-c + 1.5pt)
    content((ox + 1.2, 4.5), text(size: 10pt, fill: white, weight: "bold")[A])
    circle((ox + 3.8, 4.5), radius: r, fill: grey-c, stroke: grey-c + 1.5pt)
    content((ox + 3.8, 4.5), text(size: 10pt, fill: white, weight: "bold")[B])
    circle((ox + 5.8, 4.5), radius: r, fill: white-c.lighten(50%), stroke: white-c + 1.5pt)
    content((ox + 5.8, 4.5), text(size: 10pt, fill: black-c)[C])
    circle((ox + 2.5, 1.8), radius: r, fill: white, stroke: barrier-c + 2pt)
    content((ox + 2.5, 1.8), text(size: 10pt, fill: barrier-c, weight: "bold")[D])

    line((ox + 1.85, 4.5), (ox + 3.15, 4.5), mark: (end: ">", fill: black-c), stroke: black-c + 1.2pt)
    line((ox + 4.45, 4.5), (ox + 5.15, 4.5), mark: (end: ">", fill: grey-c), stroke: grey-c + 1.2pt)
    line((ox + 1.5, 3.9), (ox + 2.1, 2.4), stroke: (paint: barrier-c, thickness: 1.5pt, dash: "dashed"), mark: (end: ">", fill: barrier-c))
    line((ox + 3.4, 3.9), (ox + 2.9, 2.4), stroke: (paint: grey-c, thickness: 1pt, dash: "dashed"), mark: (end: ">", fill: grey-c))

    content((ox + 5, 1.8), text(size: 9pt, fill: barrier-c, weight: "bold")[barrier!])
  })

  // Arrow between panels
  line((p2 + pw + 0.3, 3), (p2 + pw + gap - 0.3, 3), mark: (end: ">", fill: grey-c), stroke: grey-c + 2pt)

  // === STEP 3: After barrier (D greyed) ===
  panel(p3, "3. Barrier greys D", ox => {
    circle((ox + 1.2, 4.5), radius: r, fill: black-c, stroke: black-c + 1.5pt)
    content((ox + 1.2, 4.5), text(size: 10pt, fill: white, weight: "bold")[A])
    circle((ox + 3.8, 4.5), radius: r, fill: grey-c, stroke: grey-c + 1.5pt)
    content((ox + 3.8, 4.5), text(size: 10pt, fill: white, weight: "bold")[B])
    circle((ox + 5.8, 4.5), radius: r, fill: white-c.lighten(50%), stroke: white-c + 1.5pt)
    content((ox + 5.8, 4.5), text(size: 10pt, fill: black-c)[C])
    circle((ox + 2.5, 1.8), radius: r, fill: grey-c, stroke: grey-c + 1.5pt)
    content((ox + 2.5, 1.8), text(size: 10pt, fill: white, weight: "bold")[D])

    line((ox + 1.85, 4.5), (ox + 3.15, 4.5), mark: (end: ">", fill: black-c), stroke: black-c + 1.2pt)
    line((ox + 4.45, 4.5), (ox + 5.15, 4.5), mark: (end: ">", fill: grey-c), stroke: grey-c + 1.2pt)
    line((ox + 1.5, 3.9), (ox + 2.1, 2.4), mark: (end: ">", fill: black-c), stroke: black-c + 1.2pt)
    line((ox + 3.4, 3.9), (ox + 2.9, 2.4), stroke: (paint: grey-c, thickness: 1pt, dash: "dashed"), mark: (end: ">", fill: grey-c))
  })
})]

The tricolour abstraction @jones2012: *Black* (fully scanned), *Grey* (children pending), *White* (not yet visited). \
*Key invariant:* no black #sym.arrow white without grey in between. Write barriers enforce this, which is what makes *concurrent* collection possible.

== Generational Garbage Collection

Empirical observation (*weak generational hypothesis*): in virtually all programs, the vast majority of objects die shortly after allocation @jones2012. This motivates splitting the heap by age:

#align(center)[#cetz.canvas(length: 1.2cm, {
  import cetz.draw: *

  let young-c = rgb("#40a02b")
  let old-c = rgb("#1e66f5")
  let arrow-c = rgb("#8839ef")

  // Young gen (top)
  rect((0, 4), (8, 7), fill: young-c.lighten(80%), stroke: young-c + 1.5pt, radius: 4pt)
  content((4, 6.4), text(size: 12pt, weight: "bold", fill: young-c.darken(20%))[Young Generation (Nursery)])
  content((4, 5.7), text(size: 10pt, fill: young-c.darken(10%))[collected frequently, very cheap])

  circle((1.15, 4.7), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))
  circle((2.15, 4.7), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))
  circle((3.15, 4.7), radius: 0.3, fill: young-c.lighten(40%), stroke: young-c)
  circle((4.0, 4.7), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))
  circle((4.85, 4.7), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))
  circle((5.85, 4.7), radius: 0.3, fill: young-c.lighten(40%), stroke: young-c)
  circle((6.85, 4.7), radius: 0.3, fill: rgb("#dce0e8"), stroke: rgb("#bcc0cc"))

  // Promotion arrow
  line((4, 3.9), (4, 2.6), mark: (end: ">", fill: arrow-c), stroke: arrow-c + 2pt)
  content((5.5, 3.25), text(size: 10pt, fill: arrow-c, weight: "bold")[promote survivors])

  // Old gen (bottom)
  rect((0, 0), (8, 2.5), fill: old-c.lighten(85%), stroke: old-c + 1.5pt, radius: 4pt)
  content((4, 1.9), text(size: 12pt, weight: "bold", fill: old-c.darken(20%))[Old Generation])
  content((4, 1.2), text(size: 10pt, fill: old-c.darken(10%))[collected rarely, more expensive])

  circle((2.5, 0.6), radius: 0.35, fill: old-c.lighten(50%), stroke: old-c)
  circle((4, 0.6), radius: 0.35, fill: old-c.lighten(50%), stroke: old-c)
  circle((5.5, 0.6), radius: 0.35, fill: old-c.lighten(50%), stroke: old-c)
})]

== Nursery collection: why it's fast

The nursery uses *bump-pointer allocation* (just increment a pointer) and is reclaimed *in bulk*. The collector never visits dead objects individually:

#align(center)[#cetz.canvas(length: 1.1cm, {
  import cetz.draw: *

  let live-c = rgb("#40a02b")
  let dead-c = rgb("#ccd0da")
  let box-bg = dead-c.lighten(40%)
  let border-c = rgb("#9ca0b0")
  let accent = rgb("#8839ef")

  content((5, 7.5), text(size: 14pt, weight: "bold")[Before collection])

  rect((0, 1), (10, 5.5), fill: box-bg, stroke: border-c + 1.5pt, radius: 4pt)
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
  content((9.5, 0.3), text(size: 10pt, fill: accent)[bump ptr])

  content((5, -0.4), text(size: 11pt)[9 dead, 2 live. Collector *never touches* dead ones.])

  line((11, 3.25), (12.5, 3.25), mark: (end: ">", fill: accent), stroke: accent + 2.5pt)

  content((18.5, 7.5), text(size: 14pt, weight: "bold")[After collection])

  rect((21, 5.8), (22, 7.1), fill: live-c.lighten(50%), stroke: live-c + 1.5pt, radius: 2pt)
  rect((22.3, 5.8), (23.3, 7.1), fill: live-c.lighten(50%), stroke: live-c + 1.5pt, radius: 2pt)
  content((22.15, 7.6), text(size: 9pt, fill: live-c)[promoted])

  rect((13.5, 1), (23.5, 5.5), stroke: border-c + 1.5pt, fill: box-bg, radius: 4pt)
  content((18.5, 6), text(size: 11pt, weight: "bold")[Nursery (reset)])

  content((18.5, 3.25), text(size: 14pt, fill: border-c, weight: "bold")[entire space reclaimed])

  line((13.8, 1), (13.8, 5.5), stroke: accent + 2pt)
  content((13.8, 0.3), text(size: 10pt, fill: accent)[bump ptr])

  content((18.5, -0.4), text(size: 11pt)[Nursery wiped. Bump ptr resets. *Zero per-object cost.*])
})]

== The price of Garbage Collection

Garbage Collection needs *heap headroom* to perform well:

- Matches `malloc`/`free` throughput only at *5× min heap* @hertz2005
- Typical overhead: #sym.tilde 17% @hertz2005
- Typical config: *1.3--4× minimum heap* @jones2012

On *memory-constrained devices*, this headroom is a luxury.

#misconception[_"GC is slow."_ Naive STW mark-sweep is slow. Modern concurrent generational collectors avoid most pauses and reclaim nurseries in bulk at near-zero cost.]

== Garbage Collection on Android

*ART* (Android Runtime) is the VM that replaced Dalvik in Android 5.0. All Kotlin/Java apps run on it.

As of Android 14, ART has two production collectors @sareen2024:
- *Concurrent Copying* collector (generational, default)
- *Concurrent Mark-Compact* collector (newer, reduces fragmentation)

Collection is *concurrent* but uses a single GC thread (*HeapTaskDaemon*), not parallel multi-threaded collection like server JVMs @sareen2024. Lower bound on GC overhead: *2--51%* across real-world apps @sareen2024.

== Android's memory challenges

Mobile GC faces unique constraints not seen on servers:

- *No memory overcommit:* Android sets fixed per-app heap budgets; no swapping @lebeck2020
- *Kill, don't swap:* under memory pressure, Android kills background apps. Restarting takes *4--27× longer* than reading from swap @lebeck2020
- *16 ms frame budget* at 60 Hz (less at 90/120 Hz): any GC pause = visible jank
- *Apps fight back:* popular apps (Instagram, Google Maps) introspect their own heap and adjust behavior based on available memory, creating feedback loops @sareen2024

#didyouknow[Popular apps allocate large heaps (60--260 MB) but *actively access* only a fraction (#sym.lt 30 MB). The rest is aggressively cached data; discarding it forces expensive network refetches @lebeck2020.]
