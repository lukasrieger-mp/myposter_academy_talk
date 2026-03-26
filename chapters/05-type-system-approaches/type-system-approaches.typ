#import "../../setup.typ": *

= Ownership & Borrowing

== The third way: ownership

GC and RC both pay at runtime. What if the *type system* handled memory?

Rust's answer: each value has *one owner*. Assignment = *move*. Old binding invalid.

```rust
fn main() {
    let s = String::from("hello");  // s owns the String
    let t = s;                       // ownership moves to t
    // println!("{}", s);            // compile error: s is invalid
    println!("{}", t);               // OK
}   // t is dropped here, memory freed
```

Formal foundation: *affine types* (Girard, 1987). Values used *at most once*. No GC, no RC. Deallocation: *deterministic*, *scope-based*, *zero runtime cost*.

== Borrowing

#slide(composer: (1fr, 1fr))[
  Move on every access = impractical. *Borrowing* grants temporary access.

  === Shared borrows (`&T`)
  Read-only. Multiple allowed.

  ```rust
  fn len(s: &String) -> usize {
      s.len()
  }
  let s = String::from("hi");
  println!("{}", len(&s)); // borrow
  ```
][
  === Mutable borrows (`&mut T`)
  Read-write. Only *one* at a time.

  ```rust
  fn push(s: &mut String) {
      s.push('!');
  }
  let mut s = String::from("hi");
  push(&mut s);
  println!("{s}"); // prints "hi!"
  ```

  *The rule:* _one mutable_ or _any number of shared_, never both.
]

== Lifetimes and escape hatches

#slide(composer: (1fr, 1fr))[
  === Lifetimes
  Compiler tracks *lifetimes*: every reference must remain valid.

  ```rust
  fn first_word(s: &str) -> &str {
      &s[..s.find(' ')
           .unwrap_or(s.len())]
  }
  ```

  Mostly inferred. Dangling pointers = *compile errors*.
][
  === The escape hatch
  When you need *shared ownership*:

  ```rust
  use std::rc::Rc;

  let a = Rc::new(vec![1, 2, 3]);
  let b = Rc::clone(&a); // rc = 2
  ```

  `Rc<T>` / `Arc<T>` = reference counting, opt-in. Reintroduces cycle risk.
]

== No free lunch

#slide(composer: (1fr, 1fr))[
  === What you get

  - Memory safety *without runtime overhead*
  - No GC pauses, no refcount traffic
  - No heap headroom tax
  - Bugs surface at *compile time*
][
  === What you pay

  - Borrow checker rejects valid-looking code
  - Graphs, linked lists, observers need `unsafe` or smart pointers
  - `Copy` = implicit memcpy (cheap for `i32`, costly for large structs)
  - `Clone` makes duplication explicit, but adds verbosity
  - Ownership analysis lengthens compile times
]
