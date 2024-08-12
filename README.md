# rpmfile

A library for reading metadata from [RPM] packages (supports version 3.0 and partially 4.0).

> [!WARNING]  
> Active development on version 0.3 is ongoing.

## Installation

You can install the library using OPAM package manager:

```console
$ opam install rpmfile rpmfile_unix rpmfile_eio
```

## Usage

The `Rpmfile` module only provides types and functions for easy field access. To read packages you need to use _readers_.

- Original reader (since the first version) powered by [Angstrom].
- And new [Eio]-based reader for more modern age.

....

### Limitations

For integer representation, native int is used by default, which is theoretically sufficient on 64-bit systems. Otherwise, use manual decoding of the value.

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
