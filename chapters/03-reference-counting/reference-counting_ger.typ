#import "../../setup.typ": *

= Reference Counting

== Reference Counting

*Kernidee:* jedes Objekt zählt seine Referenzen.

- Zähler im Object Header
- Inkrementiert bei neuer Referenz, dekrementiert bei Entfernung
- Freigegeben sobald Zähler *null* erreicht

```swift
var a: MyObject? = MyObject() // refcount = 1
var b = a                     // refcount = 2
b = nil                       // refcount = 1
a = nil                       // refcount = 0 → freed!
```

== Die Kosten des Zählens

#slide(composer: (1fr, 1fr))[
  Jeder Pointer-Schreibzugriff wird *Read-Modify-Write*:

  ```swift
  // old_ref.rc -= 1  (decrement)
  // new_ref.rc += 1  (increment)
  target = new_ref
  ```

  Selbst *Lesezugriffe* können nebenläufig Refcount-Updates auslösen.
][
  === Memory-Layout-Auswirkungen

  - Refcount-Feld in jedem Object Header
  - Im Worst Case Pointer-groß
  - Signifikanter Overhead bei kleinen Objekten
  - Refcount-Writes verschmutzen Cache mit "soon-unused" Daten
  @jones2012
]

== Deterministische Destruktion

Zentraler Vorteil: freigegeben *im Moment* der Unerreichbarkeit.

```swift
func process() {
    let file = FileHandle(path: "data.csv")
    // ... use file ...
}   // file refcount → 0, closed immediately
```

- Keine GC-Pausen
- Ressourcen (Dateien, Sockets, Locks) sofort freigegeben
- Speicherverbrauch folgt den *tatsächlich lebenden Daten*

#misconception[_"RC hat keine Pausen."_ Freigabe eines großen Objektgraphen löst kaskadierende Frees aus, die *schlimmer* als GC-Pausen sein können.]

== Das Zyklus-Problem

#slide(composer: (3fr, 2fr))[
  RC *kann Zyklen nicht* eigenständig freigeben.

  ```swift
  class Node { var next: Node? }
  let a = Node()
  let b = Node()
  a.next = b    // b.rc = 2
  b.next = a    // a.rc = 2
  // drop a, b → both still rc = 1
  // → leaked!
  ```

  Häufig: doppelt verkettete Listen, Rückverweise, Delegates.
][
  #align(center + horizon)[#cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let node-c = rgb("#d20f39")
    let ref-c = rgb("#e64553")

    rect((-0.2, 1.5), (2.5, 3.8), fill: node-c.lighten(80%), stroke: node-c + 1.5pt, radius: 4pt)
    content((1.15, 3.2), text(size: 11pt, weight: "bold")[A])
    content((1.15, 2.3), text(size: 9pt, fill: node-c)[rc = 1])

    rect((4, 1.5), (6.7, 3.8), fill: node-c.lighten(80%), stroke: node-c + 1.5pt, radius: 4pt)
    content((5.35, 3.2), text(size: 11pt, weight: "bold")[B])
    content((5.35, 2.3), text(size: 9pt, fill: node-c)[rc = 1])

    bezier((2.5, 3.2), (4.0, 3.2), (3.25, 4.2), mark: (end: ">", fill: ref-c), stroke: ref-c + 1.5pt)
    bezier((4.0, 2.1), (2.5, 2.1), (3.25, 1.1), mark: (end: ">", fill: ref-c), stroke: ref-c + 1.5pt)

    content((3.25, 0.2), text(size: 8pt, fill: rgb("#888"))[keine externen Refs #sym.arrow unerreichbar, Leak])
  })]
]

== Zyklen brechen in Swift

#slide(composer: (1fr, 1fr))[
  === `weak` Referenzen
  Inkrementieren *Strong* Refcount nicht. \
  Auto-nil bei Deallokation.

  ```swift
  class Child {
    weak var parent: Parent?
  }
  ```
][
  === `unowned` Referenzen
  Inkrementieren *Strong* Refcount nicht. \
  Geprüft beim Zugriff; Fatal Error falls Ziel weg.

  ```swift
  class Customer {
    unowned let bank: Bank
  }
  ```
]

== Warum Swift ARC gewählt hat

Trotz Zyklen führten Plattform-Constraints Apple zu *ARC*. Weak Refs müssen manuell identifiziert werden (subtile Fehlerquelle), aber ARC bietet den besten iOS-Trade-off:

- *Echtzeit:* Animationen und Touch verlangen vorhersagbare Latenz
- *ObjC-Interop:* natürliche Evolution von manuellem Retain/Release
- *Speichereffizienz:* kein Heap-Headroom eines Tracing GC nötig
- *Deterministische Bereinigung:* sofortige Freigabe für beschränkte Geräte
