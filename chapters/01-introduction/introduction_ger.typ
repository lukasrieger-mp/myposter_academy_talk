#import "../../setup.typ": *

= Wer gibt den Speicher frei?

== Warum sollte euch das interessieren?

Ihr schreibt jeden Tag Kotlin und Swift. Die JVM und ARC verwalten den Speicher.

Aber habt ihr euch schon mal gefragt...

- Warum nutzt Android *Garbage Collection*, iOS *Reference Counting*?
- Warum `[weak self]` in jeder Swift-Closure, aber nie in Kotlin?
- Warum zeigt der Android-Profiler GC-Pausen, iOS nicht?

*Designentscheidungen* mit echten Auswirkungen auf eure Apps.

== Der Heap

- Lokale Variablen: *Stack* (automatisch, begrenzt)
- Langlebige Daten: *Heap* (flexibel, manuelle Lebensdauer)
- Allokation ist einfach...

```c
char *buf = malloc(128);   // allocate
// ... use buf ...
free(buf);                  // deallocate
```

#alert[Die schwierige Frage: _wann_ darf man `free` aufrufen?]

== Zwei Wege, es falsch zu machen

#slide(composer: (1fr, 1fr))[
  === Use-after-free

  Zu *früh* freigegeben: Dangling Pointer bleibt.

  ```c
  free(buf);
  // later...
  printf("%s", buf); // undefined!
  ```

  Abstürze, Datenkorruption, ausnutzbare CVEs.
][
  === Memory Leak

  Zu *spät* (oder nie) freigegeben: Speicher unreclaimed.

  ```c
  void process() {
    char *tmp = malloc(1024);
    if (error) return; // leaked!
    free(tmp);
  }
  ```

  Wachsender Footprint, Ressourcenerschöpfung.
]

== Die grundlegende Schwierigkeit

@wilson1992: Sichere Deallokation ist schwer, weil Lebendigkeit eine _globale_ Eigenschaft ist, `free` aber eine *lokale* Entscheidung.

- Sicheres Freigeben erfordert Beweis: *keine lebende Referenz* existiert, nirgends
- C und C++ überlassen das dem Programmierer
- `unique_ptr` hilft, aber `shared_ptr` bringt RC mit *Zyklus-Problemen*

#alert[Das motiviert _automatische_ Ansätze, aber welchen?]

== Der Designraum

#align(center)[
  #cetz.canvas(length: 1.1cm, {
    import cetz.draw: *

    let box-w = 2.8
    let box-h = 1.6
    let gap = 3.6
    let colors = (rgb("#dc8a78"), rgb("#8839ef"), rgb("#fe640b"), rgb("#40a02b"))
    let labels = ("Manuell", "Tracing GC", "Ref Counting", "Typsystem")
    let langs = ("C / C++", "Java / Kotlin", "Swift / ObjC", "Rust")
    let descs = ("Programmierer\nentscheidet", "Runtime\nentscheidet", "Compiler\nfügt ein", "Compiler\nerzwingt")

    for i in range(4) {
      let x = i * gap
      rect(
        (x - box-w/2, -box-h/2), (x + box-w/2, box-h/2),
        fill: colors.at(i).lighten(75%),
        stroke: colors.at(i) + 1.5pt,
        radius: 4pt,
      )
      content((x, 0.35), text(weight: "bold", size: 11pt, labels.at(i)))
      content((x, -0.05), text(size: 9pt, fill: rgb("#555"), langs.at(i)))
      content((x, -0.45), text(size: 8pt, fill: rgb("#777"), descs.at(i)))
    }

    for i in range(3) {
      let x1 = i * gap + box-w/2 + 0.1
      let x2 = (i + 1) * gap - box-w/2 - 0.1
      line((x1, 0), (x2, 0), mark: (end: ">", fill: black), stroke: 1.2pt)
    }

    content((gap * 1.5, -1.3), text(size: 10pt, fill: rgb("#555"))[Mehr Runtime-Support #sym.arrow.long Mehr Compile-Time-Garantien])
  })
]

#text(size: 0.85em)[Vier große Paradigmen, aber der Raum ist *viel reicher*: Arenas (Zig), Regions (Pony), Generational References (Vale), Hardware-Ansätze (CHERI).]

#align(center)[_Eine Designentscheidung, geprägt durch die Constraints der Zielplattform._]
