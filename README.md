# rpmfile

A library for reading metadata from [RPM] packages (supports version 3.0 and partially 4.0).

## Installation

You can install the library using OPAM package manager:

```console
$ opam install rpmfile
$ opam install # rpmfile-unix / rpmfile-eio
```

## Usage

The `Rpmfile` module only provides types and functions for easy field access. To read packages you need to use _readers_.

| Package        | Description                                                     | Require OCaml |
| -------------- | --------------------------------------------------------------- | ------------- |
| `rpmfile-unix` | Original reader (since the first version) powered by [Angstrom] | > 4.14        |
| `rpmfile-eio`  | New [Eio]-based reader for more modern age                      | > 5.1         |

### Theoretical minimum

Each RPM package consists of four sections: lead, signature, header, and payload. The first three are meta information about the package. It contains a description, a dependency list, and so on.

The information in the signature and header is stored on a key-value basis, where the key is called a tag. The value can be a number, a string or an array.

Often you don't need all information about a package, but only some tags. For this task, a selector (predicate function) is used to determine which tags should be parsed and which should not. This greatly increases parsing speed and saves memory.

### Read package

For an example, let's use the `Rpmfile_unix`reader.

```ocaml
(* Create a reader to read all tags. *)
module Rpm_pkg_reader = module Rpmfile_unix.Reader.Make (Rpmfile.Selector.All)

let () =
  let metadata =
    Rpm_pkg_reader.of_file "hello-2.12.1-1.7.x86_64.rpm"
    |> Result.get_ok
  in

  (* Get the package name by field access function. *)
  Printf.printf "Package Name: %s\n" @@ Rpmfile.name metadata
```

### Custom selector

You may write your own selector.

```ocaml
module My_custom_selector : Rpmfile.Selector.S = struct
  (* ... *)
end
```

### Limitations

The implementation uses native OCaml int (32/64 bit depending on your machine) for some internal service values (e.g. as an offset), which may have limitations.

Also, decoding values with field access functions converts any int to native int, which may break on 32-bit systems.

## Documentation

See the [API references](https://ocaml.org/p/rpmfile/latest/doc/index.html).

## Contribution

The project is stable, but the library could be more complete. I look forward to your pull requests!
If you encounter a bug, then please create an [issue](https://github.com/dx3mod/rpmfile/issues).

### References

- [Package File Format](https://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html), [V4 Package format](https://rpm-software-management.github.io/rpm/manual/format_v4.html)
- Related
  - Alternative my implementation in TypeScript &mdash; [rpm-parser](https://github.com/dx3mod/rpm-parser)
  - [Live coding stream](https://youtu.be/tsI-ZypQ9O0?si=Oghi1yv-2BRkUb7r) (in Russian) demo version of the parser

[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager
[Angstrom]: https://github.com/inhabitedtype/angstrom
[Eio]: https://github.com/ocaml-multicore/eio
