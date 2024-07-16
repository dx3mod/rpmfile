# rpmfile

A library for reading metadata from RPM packages. Built as an [Angstrom] parser to support any use case.

## Usage

Before you can read an RPM package, you must create a `Reader` module with a selector (predicate for parsing only necessary tags) passed to it. 

```ocaml
module Rpm_reader = Rpmfile.Reader (Rpmfile.Selector.All)

let metadata = Rpm_reader.of_file_exn "hello-2.12.1-1.7.x86_64.rpm"

Rpmfile.summary metadata
(* - : string = "A Friendly Greeting Program" *)
```

You can also have “direct” access to values by tag using the `get` function. 
Example of getting file sizes:
```ocaml
Rpmfile.get Rpmfile.D.(array int) 1028 metadata
(* int list = [35000; 0; 93787; ...]*)
```

If there's a retrieval error, the `Rpmfile.Not_found` exception will be thrown.

#### Custom selector 

```ocaml
module SelectNameOnly = struct
  include Rpmfile.Selector.All

  let select_header_tag = function 
  | 1000 (* name *) -> true
  | _ -> false
end

module _ = Rpmfile.Reader (SelectNameOnly)
```

## Documentation

Lookup documentation using the [`odig`](https://github.com/b0-system/odig):
```bash
odig rpmfile
```

## References

- [Package File Format](https://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html)
- Related
  - Alternative my implementation in TypeScript &mdash; [rpm-parser](https://github.com/dx3mod/rpm-parser) 
  - [Live coding stream](https://youtu.be/tsI-ZypQ9O0?si=Oghi1yv-2BRkUb7r) (in Russian) demo version of the parser


[Angstrom]: https://github.com/inhabitedtype/angstrom