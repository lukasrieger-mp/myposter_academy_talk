#import "../../setup.typ": *

= Zusammenfassung

== Das Spektrum

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 8pt,
  align: (left, center, center, center, center),
  table.header(
    [*Ansatz*], [*Kontrolle*], [*Sicherheit*], [*Runtime-Kosten*], [*Ergonomie*],
  ),
  [*Manuell* (C)], [Programmierer], [Keine (Vertrauen)], [Null], [Hohes Risiko],
  [*Tracing GC* (JVM)], [Runtime], [Vollständig], [Pausen + Headroom], [Transparent],
  [*ARC* (Swift)], [Compiler-eingefügt], [Sicher; leakt Zyklen], [Pro-Write-Overhead], [Weitgehend transparent],
  [*Affine Types* (Rust)], [Typsystem], [Vollständig], [Null], [Lernkurve],
)

#tldr[Keine Silver Bullet. GC tauscht Speicher gegen Durchsatz. RC tauscht Pro-Write-Kosten gegen niedrigen Speicher. Ownership tauscht Ergonomie gegen null Runtime-Kosten.]

== Zentrale Erkenntnisse

+ *Speicherverwaltung ist eine Designentscheidung*, geprägt durch Plattform-Constraints

+ *Tracing GC:* Durchsatz mit kurzlebigen Objekten, braucht Heap-Headroom

+ *Reference Counting:* deterministische Bereinigung, niedriger Overhead, aber Zyklen und Pro-Write-Kosten

+ *Ownership:* Compile-Time-Sicherheit, null Runtime-Kosten, steilere Lernkurve

+ GC und RC *konvergieren* mit zunehmender Optimierung. Die Grenze ist dünner als gedacht

== Also, wer gibt den Speicher frei?

#align(center)[
  #text(size: 1.1em)[
    Hängt von den *Constraints eurer Plattform* ab. \
    #v(0.3em)
    Kotlin: die *Runtime* (Tracing GC). \
    Swift: der *Compiler* (ARC). \
    Rust: das *Typsystem* (Ownership). \
    #v(0.3em)
    Jeder zahlt einen anderen Preis. Jetzt wisst ihr *warum*.
  ]
]

#v(1em)
#align(center)[*Danke! Fragen?*]

== Referenzen

#set text(size: 0.7em)
#bibliography("/references.bib", style: "ieee", title: none)
