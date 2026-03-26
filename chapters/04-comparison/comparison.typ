#import "../../setup.typ": *

// No section divider -- this is a single transitional slide between RC and Ownership

== GC vs ARC: when to use which

#grid(columns: (1fr, 1fr), column-gutter: 1em,
  [
    === Tracing GC works well when...

    - High allocation rate, most objects short-lived
    - Heap memory plentiful
    - Developer productivity prioritized
    - Cycles are common

    _Weak:_ headroom (1.3--4×), pauses, #sym.tilde 17% overhead @hertz2005
  ],
  [
    === RC works well when...

    - Memory constrained (no headroom needed)
    - Deterministic cleanup critical
    - Latency predictability matters most
    - Interop with manual memory management

    _Weak:_ per-write overhead, cache pollution, cycles @jones2012
  ],
)

#didyouknow[As both are optimized, GC and RC *converge* @bacon2004. But both pay a runtime price...]
