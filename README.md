# Rpmfile

A library for reading [RPM packages][RPM] (supports version 3.0 and partially 4.0) powered by [Angstrom].

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
> **Theoretical minimum**
> 
> Each [RPM package](https://en.wikipedia.org/wiki/RPM_Package_Manager) consists of four sections: lead, signature, header, and payload. The first three are meta information about the package. It contains a description, a dependency list, and so on.
> 
> The information in the signature and header is stored on a key-value basis, where the key is called a tag. The value can be a number, a string or an array.
> 
> Often you don't need [all information](https://rpm-software-management.github.io/rpm/manual/tags.html) about a package, but only some tags. For this task, a selector (like predicate function) is used to determine which tags should be parsed and which should not. This greatly increases parsing speed and saves memory.

```ocaml
# #require "rpmfile";;
```

```ocaml
let pkg =
  In_channel.with_open_bin Sys.argv.(1) Rpmfile.Reader.of_channel
  |> Result.get_ok
```

```ocaml
# Rpmfile.View.name pkg;;
- : string = "hello"
```

For more details see source code and [examples](./examples/).

> [!WARNING] 
> **Limitations**
> 
> The implementation uses OCaml int (31/63 bit depending on your machine) for some internal service values (e.g. as an offset), which may have limitations.
> Also, decoding values with field access functions converts any int to OCaml int, which may break on 32-bit systems.

[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager
[Angstrom]: https://github.com/inhabitedtype/angstrom