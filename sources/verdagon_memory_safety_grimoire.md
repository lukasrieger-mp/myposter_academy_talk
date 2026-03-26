# The Memory Safety Grimoire
## Source: https://verdagon.dev/grimoire/grimoire
## Saved: 2026-03-25

A comprehensive catalogue of memory safety approaches, by Evan Ovadia (verdagon).

---

## 1. Move-Only Programming
Every object can only be known to one variable/field/array element at a time. The owner can transfer it to another location or function parameter/return.
**Languages:** Rust (with borrow checking), Austral (adds linear typing), Vale (linear-aliasing model)
**Trade-offs:** Fast, prevents aliasing issues, enables inline data. Requires "acrobatics" for patterns like temporarily removing items from hash maps.

## 2. Reference Counting
Objects track how many references point to them; deallocated when count reaches zero.
**Languages:** Python (coexists with tracing GC), Nim, Rc<T> in Rust
**Trade-offs:** Simple, uses less memory than GC. Slow, can leak cycles.

## 3. Borrow Checking
Ensuring that we only use pointers temporarily (in certain scopes) and in restricted ways to ensure others won't change the data that you're reading.
**Languages:** Rust, Austral
**Trade-offs:** Fast as C, nearly as safe as Haskell, enables Higher RAII with linear types. Prevents patterns like observers, intrusive data structures, many RAII forms; single-ownership introduces failure conditions.

## 4. Arena-Only Programming
Never use malloc/free; always use arenas for allocations, even for function returns.
**Languages:** C, Ada, Zig, Odin (with automatic allocator decoupling)
**Trade-offs:** Predictable allocation patterns. More of a memory management than safety approach on its own; Cyclone and Ada/SPARK add pointer-to-arena tracking to prevent use-after-frees.

## 5. Ada/SPARK Pointer Constraints
A pointer cannot point to an object that is more deeply scoped than itself. Pointers can only point to objects in same or outer scope levels.
**Languages:** Ada, SPARK

## 6. Regions
Establishes isolated subgraphs of objects where one reference holds exclusive access. Can be temporarily opened as immutable regions within scopes, eliminating memory safety costs.
**Languages:** Pony (iso keyword), Forty2, Verona, Vale

## 7. Stack Arenas
Automatic arena allocation for every stack frame.
**Languages:** Elucent's Basil

## 8. Generational References
Prevents use-after-frees by comparing a pointer's "remembered" generation number to the object's current generation number; increment generation when destroying.
**Languages:** Vale

## 9. Random Generational References
Faster variant that lets us have "inline data" by putting structs on stack, inside arrays, or inline in other structs. Generation lives next to object.
**Languages:** Vale

## 10. MMM++ (Memory Management Model)
Objects allocated from global arrays; slots released and reused for same-type objects, preventing use-after-free.
**Languages:** Arrrlang (theoretical), used in embedded/safety-critical/real-time software

## 11. Tracing Garbage Collection
Automatic collection through heap traversal. Pony separates each actor into its own world with individual garbage collection via ORCA mechanism.
**Languages:** Java, Python, JavaScript, Pony, Verona

## 12. Interaction Nets
Very fast way to manage purely immutable data without garbage collection or reference counting. Uses affine types with extremely efficient lazy .clone() primitive.
**Languages:** HVM (Haskell runtime)

## 13. Constraint References
Blend of reference counting and single ownership. Every object has single owner, counter for all references; assertion that no references exist before destruction.
**Languages:** Game development (informal use), Gel

## 14. Linear Reference Counting
Completely eliminate the counter integer, and do all of the reference counting at compile time using tine references and fork references.
**Languages:** Hypothetical (not yet implemented)

## 15. Not-MVS (Not-Mutable Value Semantics)
Like a Java or Swift where every object has exactly one reference pointing to it at any given time, but that reference can be lent out to a function call. Like Rust with no shared references (&), only unique references (&mut).
**Languages:** Theoretical

## 16. CHERI (Capability Hardware Enhanced RISC Instructions)
Hardware-software blend using 128-bit pointers containing address range, permissions, and 1-bit hardware tag. Cornucopia adds temporal safety.
**Languages:** C (memory-safe variant), CHERIoT

## 17. Neverfree
Just don't call free! If you never free memory, you can't use-after-free.
**Languages:** Missiles (documented real-world case), short-lived programs

---

## Key Supporting Concepts
- **Type stability:** Real enemy is "use after shape change," not just use-after-free
- **Unique references:** Key breakthrough in borrow checking, MVS, move-only programming
- **Thread isolation:** Enables borrow checking, generational references, faster reference counting
- **Fat pointers:** Rust trait references, Vale's generational references
- **Top-byte ignore:** CPU feature allowing metadata storage in pointer's high byte
- **Check-on-set:** Runtime modification validation (e.g., JavaScript Object.freeze)
