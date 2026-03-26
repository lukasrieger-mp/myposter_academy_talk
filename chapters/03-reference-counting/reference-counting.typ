#import "../../setup.typ": *

= Reference Counting

== How reference counting works

Unlike tracing GC, RC has no separate collector. Instead, each object maintains a *reference count* in its header @jones2012:

- On pointer write: increment new target's rc, decrement old target's rc
- When rc drops to *zero*: free object and recursively decrement its children

```swift
var a: MyObject? = MyObject() // rc = 1
var b = a                     // rc = 2
b = nil                       // rc = 1
a = nil                       // rc = 0 → freed!
```

== Advantages and trade-offs

#grid(columns: (1fr, 1fr), column-gutter: 1em,
  [
    === Advantages

    - *Deterministic:* freed when unreachable
    - *Low memory overhead:* works in near-full heaps @jones2012
    - *No collector pauses:* no separate GC phase, cost distributed across mutations
  ],
  [
    === Trade-offs

    - Every pointer write = *read-modify-write*
    - Cache pollution from refcount writes @jones2012
    - Per-object header overhead
    - *Cannot reclaim cycles*
  ],
)

#misconception[_"RC has no pauses."_ Cascading frees can spike *worse* than GC pauses @jones2012.]

== The cycle problem

RC *cannot reclaim cycles*. Even if unreachable from roots, internal references keep rc > 0. Common: "doubly-linked lists, trees with back pointers" @jones2012.

#v(0.5em)

#align(center)[#cetz.canvas(length: 1.6cm, {
  import cetz.draw: *

  let node-c = rgb("#d20f39")
  let ref-c = rgb("#e64553")

  rect((0, 0.5), (3, 3.2), fill: node-c.lighten(80%), stroke: node-c + 1.5pt, radius: 4pt)
  content((1.5, 2.5), text(size: 13pt, weight: "bold", fill: node-c.darken(20%))[A])
  content((1.5, 1.4), text(size: 11pt, fill: node-c.darken(10%))[rc = 1])

  rect((5, 0.5), (8, 3.2), fill: node-c.lighten(80%), stroke: node-c + 1.5pt, radius: 4pt)
  content((6.5, 2.5), text(size: 13pt, weight: "bold", fill: node-c.darken(20%))[B])
  content((6.5, 1.4), text(size: 11pt, fill: node-c.darken(10%))[rc = 1])

  bezier((3, 2.5), (5, 2.5), (4, 3.5), mark: (end: ">", fill: ref-c), stroke: ref-c + 1.5pt)
  bezier((5, 1.2), (3, 1.2), (4, 0.2), mark: (end: ">", fill: ref-c), stroke: ref-c + 1.5pt)

  content((4, -0.5), text(size: 10pt, fill: rgb("#838ba7"))[no external refs #sym.arrow unreachable, leaked])
})]

== Breaking cycles in Swift

- `weak var`: doesn't increment *strong* rc, auto-zeroed to `nil` on dealloc
- `unowned let`: doesn't increment *strong* rc, checked at access, fatal error if gone

```swift
class Child {
    weak var parent: Parent?  // won't create a cycle
}
```

== Why did iOS choose RC, Android GC?

#slide(composer: (1fr, 1fr))[
  === iOS / Swift: ARC

  - Early iPhones: 128--256 MB RAM, no room for GC headroom
  - Objective-C already had manual retain/release
  - ARC = compiler automates existing practice
  - Deterministic cleanup critical for constrained devices
][
  === Android / Kotlin: Tracing GC

  - JVM heritage: GC built into Dalvik/ART from the start
  - Server-style heap management, generous memory budgets
  - GC excels at short-lived objects (dominant in app workloads)
  - Concurrent GC mitigates pause concerns
]
