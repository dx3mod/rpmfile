# Rpmfile

A library for reading [RPM packages][RPM] (supports version 3.0 and partially 4.0) 
powered by [Angstrom].

## Installation

Installation by OPAM package manager 
```console
$ opam install rpmfile
```
or pin the latest development version from GitHub.
```console
$ opam pin https://github.com/dx3mod/rpmfile.git
```

## Usage

> [!NOTE]  
> Theoretical minimum
> 
> Each [RPM package](https://en.wikipedia.org/wiki/RPM_Package_Manager) consists of four sections: lead, signature, header, and payload. The first three are meta information about the package. It contains a description, a dependency list, and so on.
> 
> The information in the signature and header is stored on a key-value basis, where the key is called a tag. The value can be a number, a string or an array.
> 
> Often you don't need [all information](https://rpm-software-management.github.io/rpm/manual/tags.html) about a package, but only some tags. For this task, a selector (like predicate function) is used to determine which tags should be parsed and which should not. This greatly increases parsing speed and saves memory.

To read RPM packages, you should create an instance of the Reader module with defined selectors (a mechanism for parsing only the necessary tags). 

Out of the box, the library has a default reader that reads all tags, but without the body.

```ocaml
module Rpm_pkg_reader = Rpmfile.Reader.Default
(* equivalents *)
module Rpm_pkg_reader = Rpmfile.Reader.Make (Rpmfile.Selector.Default)
```

```ocaml
let hello_pkg = 
  In_channel.with_open_bin "hello.rpm" Rpm_pkg_reader.of_channel 
  |> Result.get_ok
```

```ocaml
# Rpmfile.View.name hello_pkg;;
- : string = "hello"

# Rpmfile.View.build_time hello_pkg;;
- : int = 1653906083
```

For more details see source code and [examples](./examples/).


## Contribution

Nice to see you xD

### Hacking

Package format specification:
- [Package File Format](https://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html)
- [V4 Package format](https://rpm-software-management.github.io/rpm/manual/format_v4.html)

Other references:
- Alternative my implementation in TypeScript &mdash; [rpm-parser](https://github.com/dx3mod/rpm-parser)
- [Live coding stream](https://youtu.be/tsI-ZypQ9O0?si=Oghi1yv-2BRkUb7r) (in Russian) demo version of the parser
- <https://github.com/rpm-rs/rpm/>

[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager
[Angstrom]: https://github.com/inhabitedtype/angstrom