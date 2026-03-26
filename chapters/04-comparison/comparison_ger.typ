#import "../../setup.typ": *

= Tracing vs Counting

== Im direkten Vergleich

#table(
  columns: (auto, 1fr, 1fr),
  inset: 8pt,
  align: (left, left, left),
  table.header([], [*Tracing GC*], [*Reference Counting*]),
  [*Kurzlebige Objekte*],
  [Gewinnt: Nursery-Bulk-Reclaim, null Pro-Objekt-Kosten],
  [Verliert: Inc/Dec bei jeder Zuweisung],

  [*Durchsatz*],
  [#sym.tilde 17% Overhead bei typischen Heap-Größen],
  [Verteilt; naives RC bei Volumen unpraktikabel],

  [*Pausenzeiten*],
  [Stop-the-World möglich; durch Concurrent GC abgemildert],
  [Meist kurz; kaskadierende Frees können ausschlagen],

  [*Heap-Overhead*],
  [1,3--4× Min-Heap (5× um malloc zu matchen)],
  [Pro-Objekt-Refcount; fast voller Heap],

  [*Zyklen*],
  [Natürlich behandelt],
  [Ohne Zusatzmechanismus nicht rückgewinnbar],
)

== Wo jeder glänzt

#slide(composer: (1fr, 1fr))[
  === Tracing GC glänzt wenn...

  - Hohe Allokationsrate, niedrige Überlebensrate
  - Kurzlebige Objekte dominieren
  - Heap-Speicher reichlich vorhanden
  - Entwicklerproduktivität priorisiert

  _Typisch:_ Server, Backends, Android-Apps
][
  === RC glänzt wenn...

  - Latenz-Vorhersagbarkeit am wichtigsten
  - Speicher begrenzt
  - Deterministische Ressourcenfreigabe nötig
  - Interop mit manueller Speicherverwaltung

  _Typisch:_ iOS/macOS-Apps, Embedded Swift
]

== Zwei Seiten derselben Medaille

@bacon2004: Tracing und RC sind *Duale* eines einheitlichen Frameworks.

- Tracing: *lebende* Objekte von Roots finden, Rest freigeben
- RC: *tote* Objekte erkennen (Zähler = 0), sofort freigeben
- Optimiertes RC (Batching Retain/Release) führt Stop-the-World wieder ein
- Concurrent/Incremental GC reduziert Pausen Richtung RC-Niveau

#didyouknow[Je mehr beide optimiert werden, desto mehr *konvergieren* sie. Aber beide zahlen Runtime-Preis. Was wäre, wenn der Compiler alles erledigen könnte?]
