# MoreSTLC — a front end in BNFC, an interpreter in Haskell

A complete **front end** (lexer, parser, abstract syntax, pretty printer) for
the language of [`MoreStlc.v`](../MoreStlc.v) — the simply typed lambda calculus
extended with **numbers, `let`, products, lists and `fix`**.

That development has **no booleans**: a single `if0` form combines the zero test
and the conditional, and `Nat` is the only base type. Sums, `Unit`, records and
variants are left out here.

The front end is generated from a single grammar file, [`MoreSTLC.cf`](MoreSTLC.cf),
by [BNFC](https://bnfc.readthedocs.io/). The driver, the environment and the
error reporting are written for you. **Your job is the type checker and the
evaluator.**

---

## 1. Building

You need `bnfc`, `alex`, `happy` and `ghc` on your `PATH`.

```bash
make
```

> **On Windows** the recipes need a POSIX toolset too, because they are plain
> Unix commands (`mkdir -p`, `rm -rf`, `sh ./test.sh`). The Makefile picks up
> the one Git for Windows installs in `<git>\usr\bin`, found next to `git.exe`;
> if git lives somewhere it cannot work out, pass the directory yourself with
> `make GIT_USR_BIN="C:\Program Files\Git\usr\bin"`. Running `make` from Git
> Bash needs none of this — that `PATH` already has the tools.

That runs three steps, which you can also run by hand:

| step | tool | input | output |
|---|---|---|---|
| 1 | `bnfc` | `MoreSTLC.cf` | `gen/AbsMoreSTLC.hs`, `gen/LexMoreSTLC.x`, `gen/ParMoreSTLC.y`, `gen/PrintMoreSTLC.hs` |
| 2 | `alex` / `happy` | `.x` / `.y` | `gen/LexMoreSTLC.hs`, `gen/ParMoreSTLC.hs` |
| 3 | `ghc` | `src/*.hs` + `gen/*.hs` | `./morestlc` |

Other targets:

```bash
make test        # run the front end test suite (works even with the stubs in place)
make clean       # remove compiled objects
make distclean   # also remove everything BNFC generated
```

`gen/` and `build/` are generated; they are not in version control. If you edit
`MoreSTLC.cf`, just run `make` again.

> **Happy must stay silent.** If step 2 prints `shift/reduce conflicts` or
> `reduce/reduce conflicts`, the grammar has become ambiguous and must be fixed.
> As shipped it reports zero of both.

## 2. Running

A file holds one term, and several files may be given at once:

```bash
./morestlc examples/04-factorial.mstlc
```

```bash
./morestlc examples/*.mstlc
```

With more than one file, each line of output is prefixed with the file it came
from.

| option | what it does |
|---|---|
| *(none)* / `--run` | parse, type check, evaluate |
| `--type-only` | parse and type check, do not evaluate |
| `--parse-only` | parse only |
| `--ast` | dump the abstract syntax tree (very useful for checking precedence) |
| `--print` | pretty print the term |
| `--roundtrip` | parse, pretty print, parse again, compare the trees |

With no file it reads standard input, so you can try one term quickly:

```bash
echo '6 * 7' | ./morestlc --ast
```

---

## 3. The language

### Relation to the Coq notations

The concrete syntax mirrors the `Notation` declarations of `MoreStlc.v`:

| `MoreStlc.v` | here | |
|---|---|---|
| `\x:T, t` | `\x:T, t` | a **comma**, not a dot |
| `t1 t2` | `t1 t2` | left associative |
| `succ t`, `pred t` | same | argument is an atom |
| `t1 * t2` | `t1 * t2` | infix, right associative |
| `if0 t1 then t2 else t3` | same | |
| `nil T` | `nil T` | no brackets around `T` |
| `t1 :: t2` | `t1 :: t2` | right associative |
| `case t1 of \| nil => t2 \| x::y => t3` | same | the leading `\|` is required |
| `(t1, t2)`, `t.fst`, `t.snd` | same | projections are postfix |
| `let x = t1 in t2`, `fix t` | same | |

Three deliberate differences, all of them chosen to keep the grammar LALR(1) and
conflict free:

* **`fix` binds at the application level**, so `fix F (pred n)` is
  `(fix F) (pred n)` — the reading the book uses when it unfolds the factorial
  by hand. Its `Notation` sits at level 200, which would give `fix (F (pred n))`.
* **`List` binds tighter than `*`**, so `List Nat * Nat` is `(List Nat) * Nat`.
  The Coq levels give the opposite. Every type in `MoreStlc.v` that mixes the
  two is parenthesized, so no example changes meaning.
* **The branches of `if0` and of `case` extend as far right as they can**,
  instead of being restricted to atoms. This only *accepts more* — everything
  that parses under the Coq notation parses here with the same meaning, so the
  parentheses in the book's examples remain valid and become optional.

### Programs

There is no program category, because `MoreStlc.v` has none: its `Inductive tm`
*is* the whole structure of a program. **A source file holds exactly one term**,
and the grammar has exactly two categories, matching the two `Inductive`s one
for one:

| `MoreStlc.v` | `MoreSTLC.cf` | `AbsMoreSTLC.hs` |
|---|---|---|
| `Inductive ty` (lines 961–967) | `Type` | `data Type` |
| `Inductive tm` (lines 969–1003) | `Term` | `data Term` |

The constructors carry the book's names too — `TmAbs`, `TmApp`, `TmConst`,
`TmLcase`, `TyArrow`, `TyNat` — and every rule in the grammar is annotated with
the `ty` or `tm` constructor it builds, so the correspondence is visible line by
line. Parsing `succ (1 :: nil Nat)` gives

```
TmSucc (TmCons (TmConst 1) (TmNil TyNat))
```

**`Term` is the only entry point.** `Type` is never parsed on its own: it occurs
only inside a term, in the annotation of an abstraction and in the element type
of `nil`.

Names are introduced the way the book introduces them, with `let ... in ...`
inside the term:

```
let double = \n:Nat, 2 * n in double 21        -- 42 : Nat
```

To report several results from one file, return a tuple — which is exactly what
the book does at the end of its `evenodd` example, `(even 3, even 4)`. The
examples all do this.

`let` is **not** recursive — in `let f = ... f ... in`, the `f` on the right is
not the one being bound. Recursion is written with `fix`, exactly as in the
book. See `examples/07-let.mstlc`.

Comments are `--` to end of line, and `(* ... *)` as in Coq (but they do not
nest).

### Types

```
T ::= Nat | List T | T * T | T -> T | ( T )
```

Binding strength, tightest first: **`List`**, then **`*`** (left associative),
then **`->`** (right associative). So

* `List Nat -> Nat`  is  `(List Nat) -> Nat`
* `Nat * Nat -> Nat` is  `(Nat * Nat) -> Nat`
* `Nat -> Nat -> Nat` is `Nat -> (Nat -> Nat)`
* `List List Nat`     is `List (List Nat)`

### Terms

From loosest to tightest:

| level | forms |
|---|---|
| 0 | `\x:T, t` · `let x = t in t` · `if0 t then t else t` · `case t of \| nil => t \| x::y => t` |
| 1 | `t :: t` (cons, right associative) |
| 2 | `t * t` (multiplication, right associative) |
| 3 | `t t` (application, left associative) · `succ a` · `pred a` · `fix a` |
| 4 | `t.fst` · `t.snd` (postfix, chain left to right) |
| 5 | *x* · *n* · `nil T` · `(t, t)` · `( t )` |

**`succ`, `pred` and `fix` take a level 4 argument**, not a full application.
This is part of what keeps the grammar unambiguous, and it means you sometimes
need parentheses:

```
succ (succ 0)          -- not: succ succ 0
n * (f (pred n))       -- f (pred n) needs no parens here, but they are allowed
succ p.fst             -- fine: projection is tighter than succ
box.fst box.snd        -- parses as (box.fst) (box.snd)
```

Numbers are non-negative integer literals. `pred 0` is `0`, matching
`ST_PredNat`, which computes `n - 1` on `nat`.

Reserved words: `List` `Nat` `case` `else` `fix` `if0` `in` `let` `nil`
`of` `pred` `succ` `then`. Note that `fst` and `snd` are *not* reserved: the
projections are the single tokens `.fst` and `.snd`.

---

## 4. Your assignment

Two files carry the work. Everything else is done.

### `src/TypeCheck.hs` — the static semantics

Implement

```haskell
typeOf :: Ctx -> Term -> Either TypeError Type
```

one case per rule of `has_type` in `MoreStlc.v`. The rules are written out in
the comment at the top of the file. Three cases (`T_Var`, `T_Nat`, `T_Succ`)
are filled in as worked examples, the last of them showing how to use the
`expect` helper.

### `src/Eval.hs` — the dynamic semantics

`MoreStlc.v` gives a small step relation `t --> t'`. You implement the
corresponding **big step**, **call by value** relation:

```haskell
eval :: Term -> Either RuntimeError Term
```

`eval t` returns the value `t` evaluates to. Values are represented as
expressions again, namely the ones `isValue` accepts (that function is given —
it is `Inductive value` of the book), because evaluation is defined by
**substitution**, not by closures. That is what makes `fix` easy — it is
`ST_FixAbs` read off directly:

```
t1 ==> \xf:T1, t     [xf := fix (\xf:T1, t)] t ==> v
-----------------------------------------------------
fix t1 ==> v
```

You also implement three cases of

```haskell
subst :: Ident -> Term -> Term -> Term     -- the book's [x:=s]t
```

The congruence cases are given; the three that **bind** a variable (`TmAbs`,
`TmLet`, `TmLcase`) are yours. Because the language is call by value and programs
are closed, `s` is always a closed value, so naive substitution cannot capture
anything — you do not need to rename bound variables. You *do* need to stop
substituting under a binder that shadows `x`.

### Suggested order

1. `subst` — nothing evaluates without it.
2. `TmLet` in both files. Every example introduces its names with `let`, so
   until `TmLet` works almost nothing runs.
3. Numbers: `TmSucc`, `TmPred`, `TmMult`, `TmIf0`.
   Now `examples/01-arithmetic.mstlc` runs.
4. Functions: `TmAbs`, `TmApp`. Now `examples/05-higher-order.mstlc` runs.
5. Products: `TmPair`, `TmFst`, `TmSnd` → `examples/02-pairs.mstlc`.
6. Lists: `TmNil`, `TmCons`, `TmLcase` → `examples/03-lists.mstlc`.
7. `TmFix` → `examples/04-factorial.mstlc`, `06-list-library.mstlc`, `08-evenodd.mstlc`.

Check your work by running the example files: each one carries the expected
result in a comment.

```bash
./morestlc examples/*.mstlc
```

---

## 5. Examples

Each file is a single term, with its expected value in a comment at the end.

| file | covers |
|---|---|
| `examples/01-arithmetic.mstlc` | `succ`, `pred`, `*`, `if0`, `let` |
| `examples/02-pairs.mstlc` | products, `.fst`, `.snd`, currying |
| `examples/03-lists.mstlc` | `nil T`, `::`, `case`, nested lists |
| `examples/04-factorial.mstlc` | recursion with `fix`: the factorial of the book |
| `examples/05-higher-order.mstlc` | functions as arguments, results and data |
| `examples/06-list-library.mstlc` | `length`, `sum`, `map`, `append` |
| `examples/07-let.mstlc` | what `let` does: nesting, shadowing, and that it is not recursive |
| `examples/08-evenodd.mstlc` | the book's mutually recursive pair, via one `fix` |

`examples/bad/` holds one file per way of going wrong: ten ill typed terms named
after the rule they break (`succ-of-list`, `if0-branches`,
`fix-not-endomorphism`, `let-not-recursive`, …), plus `parse-error.mstlc` —
the only one that fails in the front end rather than the type checker — and
`diverges.mstlc`.

**Type safety is not termination.** `fix (\x:Nat, x)` type checks at `Nat` and
loops forever. MoreSTLC with `fix` is Turing complete, so no type checker can
rule this out. Progress and preservation say a well typed program never gets
*stuck*, not that it stops. If your evaluator hangs, check whether the program
really terminates before blaming your code.

---

## 6. Source map

```
MoreSTLC.cf        the grammar -- the single source of the whole front end
Makefile           bnfc -> alex/happy -> ghc
test.sh            front end test suite (make test)

src/Main.hs        driver: options, reporting, error recovery            [given]
src/Env.hs         the typing context                                   [given]
src/Pretty.hs      thin layer over the BNFC pretty printer              [given]
src/TypeCheck.hs   the typing relation                        *** YOUR WORK ***
src/Eval.hs        substitution and big step evaluation       *** YOUR WORK ***

gen/               generated by BNFC -- never edit, never commit
build/             generated by GHC  -- never edit, never commit
examples/          one term per file, expected value in a trailing comment
```

`make test` checks the front end only — that the grammar is unambiguous, that
every example parses, that pretty printing round trips, and that broken syntax
is rejected. It therefore passes from day one and keeps passing while you fill
in the stubs; it is the regression test for changes to `MoreSTLC.cf`.

## 7. Going further

Once everything runs, the natural extensions are the features of `MoreStlc.v`
left out here. Each is a few lines of `MoreSTLC.cf` plus the corresponding
cases in the two modules you already wrote:

* **`Unit`** — the type `Unit` and the value `unit`. The easiest one.
* **Sums** — `T1 + T2`, `inl T t`, `inr T t`, and the sum `case`. You might
  expect trouble here, because `MoreStlc.v` writes the sum case as
  `case t0 of | inl x1 => t1 | inr x2 => t2`, which shares the whole opening
  `case ... of |` with the list form. It costs nothing: the parser only has to
  look one token past the `|` to see `inl` rather than `nil`, and that is
  exactly what an LALR(1) parser has in hand. Adding both forms the obvious way
  keeps happy at zero conflicts. (This is a good reason for the leading `|` in
  the book's notation — it puts a fixed marker in front of the token that
  decides.) The one thing that does need thought is where to put `+` relative
  to `*` in the type levels.
* **Records and variants** — n-ary, accessed by label. These need a list of
  fields in the grammar, so start with BNFC's `separator` construct.
