#import "../../setup.typ": *

= Ownership & Borrowing

== Die Erkenntnis

Manuelle Speicherverwaltung (C): *Macht* ohne *Sicherheit*. \
GC und RC: Sicherheit zu *Runtime-Kosten*.

#v(0.5em)
Was wäre, wenn das *Typsystem* die Regeln durchsetzen könnte, die der Programmierer sich merken musste?

#v(0.5em)
#align(center)[
  _Kann der Compiler beweisen, wann Werte sterben, braucht man keinen Runtime-Mechanismus._
]

== Die Kernidee: ein Besitzer

Was wäre, wenn jeder Wert *genau einen Besitzer* hätte, vom Compiler erzwungen?

- Nicht *kopierbar* (kein versehentliches Aliasing)
- Besitzer weg = Wert freigegeben (deterministisch, kostenlos)
- Compiler lehnt Verstöße ab *bevor Code läuft*

Formaler Name: *Affine Types* (Girards lineare Logik, 1987). Jeder Wert *höchstens einmal* verwendbar. Keine Duplikation = Compiler *garantiert Single Ownership zur Compile-Time*.

#text(size: 0.85em)[_Formal:_ Affine Types entfernen _Contraction_ (kein Kopieren), behalten _Weakening_ (Droppen OK). Lineare Types entfernen beide.]

== Ownership in Rust

Rust: das am weitesten verbreitete *praktische affine Typsystem*.

Jeder Wert hat *einen Owner*. Owner verlässt Scope = Wert gedroppt.

```rust
fn main() {
    let s = String::from("hello");  // s owns the String
    let t = s;                       // ownership moves to t
    // println!("{}", s);            // compile error: s is invalid
    println!("{}", t);               // OK
}   // t is dropped here, memory freed
```

Kein GC, kein RC. Deallokation: *deterministisch*, *Scope-basiert*, *null Runtime-Kosten*.

== Borrowing

#slide(composer: (1fr, 1fr))[
  Ownership-Transfer bei jedem Zugriff = unpraktisch. *Borrowing* gewährt temporären Zugang.

  === Shared Borrows (`&T`)
  Nur-Lese. Mehrere erlaubt.

  ```rust
  fn len(s: &String) -> usize {
      s.len()
  }
  let s = String::from("hi");
  println!("{}", len(&s)); // borrow
  ```
][
  === Mutable Borrows (`&mut T`)
  Lese-Schreib. Nur *einer* gleichzeitig.

  ```rust
  fn push(s: &mut String) {
      s.push('!');
  }
  let mut s = String::from("hi");
  push(&mut s);
  println!("{s}"); // prints "hi!"
  ```

  *Die Regel:* _ein Mutable_ oder _beliebig viele Shared_, nie beides.
]

== Lifetimes und der Notausgang

#slide(composer: (1fr, 1fr))[
  === Lifetimes
  Compiler trackt *Lifetimes*: jede Referenz muss gültig bleiben.

  ```rust
  fn first_word(s: &str) -> &str {
      &s[..s.find(' ')
           .unwrap_or(s.len())]
  }
  ```

  Meist inferiert. Dangling Pointer = *Compile Errors*.
][
  === Der Notausgang
  Wenn *Shared Ownership* nötig:

  ```rust
  use std::rc::Rc;

  let a = Rc::new(vec![1, 2, 3]);
  let b = Rc::clone(&a); // rc = 2
  ```

  `Rc<T>` / `Arc<T>` = Reference Counting, opt-in.
]

== Jenseits von Borrow Checking

Rust ist eine von mehreren Sprachen für Compile-Time Memory Safety:

#table(
  columns: (auto, 1fr, auto),
  inset: 8pt,
  align: (left, left, left),
  table.header([*Ansatz*], [*Idee*], [*Sprachen*]),
  [*Regions*], [Subgraphen isolieren; Immutability macht Runtime-Checks unnötig], [Pony, Verona, Vale],
  [*Generational Refs*], [Pointer speichern Generationsnummer; beim Zugriff geprüft], [Vale],
  [*Arena-scoped*], [Allokationen an Arena-Lifetimes gebunden; Pointer können Arena nicht überleben], [Zig, Odin, Ada],
  [*Constraint Refs*], [Single Owner + Refcount als Assertion; Crash falls Refs bei Destruktion existieren], [Gel, Game Engines],
)

The Memory Safety Grimoire @grimoire: *17+ Ansätze*. Designraum bei Weitem nicht abgeschlossen.

== Der Ownership-Trade-off

#slide(composer: (1fr, 1fr))[
  === Die Reibung

  - Borrow Checker lehnt gültig aussehenden Code ab
  - Graphen, Linked Lists, Observer brauchen `unsafe` oder Smart Pointer
  - Ownership-Analyse verlängert Compile-Zeiten
][
  === Der Gewinn

  - Memory Safety *ohne Runtime-Overhead*
  - Keine GC-Pausen, kein Refcount-Traffic, keine Headroom-Steuer
  - Bugs zur *Compile Time*, nicht in Produktion
]
