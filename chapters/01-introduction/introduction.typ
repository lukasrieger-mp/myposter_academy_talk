#import "../../setup.typ": *

= Memory Management

== Why memory management matters

#grid(columns: (1fr, 1fr), column-gutter: 1em,
  [
    Every program allocates dynamic memory on the *heap*. Allocation is cheap; the hard part is knowing *when to free*.

    ```c
    free(buf);
    // later...
    printf("%s", buf); // undefined!
    ```
    Too early: *dangling pointer* (crash, CVE).
  ],
  [
    Manual management is error-prone @wilson1992: liveness is _global_, but `free` is *local*.

    ```c
    void process() {
      char *tmp = malloc(1024);
      if (error) return; // leaked!
      free(tmp);
    }
    ```
    Too late: *memory leak* (exhaustion).
  ],
)

Solution: delegate freeing to an *automatic collector*.

== What we'll cover

Three approaches to automatic memory management, each with different trade-offs:

#align(center)[#cetz.canvas(length: 1.4cm, {
  import cetz.draw: *

  let colors = (rgb("#8839ef"), rgb("#fe640b"), rgb("#40a02b"))

  let box(x, y, w, label, sublabel, col) = {
    rect((x - w/2, y - 0.7), (x + w/2, y + 0.7), fill: col.lighten(75%), stroke: col + 1.5pt, radius: 4pt)
    content((x, y + 0.2), text(size: 14pt, weight: "bold", fill: col.darken(10%))[#label])
    content((x, y - 0.3), text(size: 10pt, fill: rgb("#6c6f85"))[#sublabel])
  }

  box(2, 3, 4.5, "Tracing GC", "Java / Kotlin", colors.at(0))
  box(8, 3, 4.5, "Ref Counting", "Swift / ObjC", colors.at(1))
  box(14, 3, 4.5, "Ownership", "Rust", colors.at(2))
})]

We'll explore each, compare them, and see why different platforms made different choices.
