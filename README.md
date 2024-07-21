# rpmfile

A library for reading metadata from [RPM] packages (supports version 3.0 and partially 4.0), providing an [Angstrom] parser and a simple interface for accessing values.

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

#### CLI utility

You can also use rpmfile as a CLI utility to get information about a package, similar to `rpm -qi`.

```bash
rpmfile hello-2.12.1-1.7.x86_64.rpm
```

#### Achtung 

For integer representation, native int is used by default, which is theoretically sufficient on 64-bit systems. Otherwise, use manual decoding of the value. 

## Documentation

- Lookup documentation using [`odig`](https://github.com/b0-system/odig)
- Tutorial in Russian on [ocamlportal.ru](https://ocamlportal.ru/libraries/parsers/rpmfile)

## References

- [Package File Format](https://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html), [V4 Package format](https://rpm-software-management.github.io/rpm/manual/format_v4.html)
- Related
  - Alternative my implementation in TypeScript &mdash; [rpm-parser](https://github.com/dx3mod/rpm-parser) 
  - [Live coding stream](https://youtu.be/tsI-ZypQ9O0?si=Oghi1yv-2BRkUb7r) (in Russian) demo version of the parser

## Contribution

The project is stable, but the library could be more complete. I look forward to your pull requests!
If you encounter a bug, then please create an [issue](https://github.com/dx3mod/rpmfile/issues).

[Angstrom]: https://github.com/inhabitedtype/angstrom
[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager