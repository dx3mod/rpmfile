# rpmfile

A library for reading metadata from [RPM packages][RPM] (supports version 3.0 and partially 4.0) written in OCaml.

<!-- ## Installation

You can install the library using OPAM package manager:

```console
$ opam install rpmfile
$ opam install # rpmfile-unix / rpmfile-eio
```

Extra:
```console
$ opam install rpmfile-cli # depends by rpmfile-eio
``` -->

## Usage

The `Rpmfile` module only provides types and functions for easy field access. To read packages you need to use _readers_.

| Package        | Description                                                     | Require OCaml |
|----------------|-----------------------------------------------------------------|---------------|
| `rpmfile-unix` | Original reader (since the first version) powered by [Angstrom] | >= 4.14       |
| `rpmfile-eio`  | New [Eio]-based reader for more modern age                      | > 5.1         |

### Installation

You can install the library using OPAM package manager:

```console
$ opam install # rpmfile-unix / rpmfile-eio
```

### Theoretical minimum

Each [RPM package][PackageFileFormat] consists of four sections: lead, signature, header, and payload. The first three are meta information about the package. It contains a description, a dependency list, and so on.

The information in the signature and header is stored on a key-value basis, where the key is called a tag. The value can be a number, a string or an array.

Often you don't need [all information](https://rpm-software-management.github.io/rpm/manual/tags.html) about a package, but only some tags. For this task, a selector (like predicate function) is used to determine which tags should be parsed and which should not. This greatly increases parsing speed and saves memory.

### Read package

For an example, let's use the `Rpmfile_unix`reader.

```ocaml
(* Create a reader to read all tags. *)
module Rpm_pkg_reader = Rpmfile_unix.Reader.Make (Rpmfile.Selector.All)

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

<details>
<summary>Or just use built-in selectors</summary>

| Selector        | For                                          |
|-----------------|----------------------------------------------|
| `Selector.All`  | read all tags                                |
| `Selector.Base` | read basic tags (see docs or implementation) |

</details>

### Manual decode

You can write your own decoder if there is no convenient field access function for the tag you need.

```ocaml
let get_signature_size_field =
  Rpmfile.get_from_signature
    ~msg:"signature.size" (* Failwith message. *)
    D.int Tag.Signature.size
```

### Limitations

The implementation uses native OCaml int (32/64 bit depending on your machine) for some internal service values (e.g. as an offset), which may have limitations.

Also, decoding values with field access functions converts any int to native OCaml int, which may break on 32-bit systems.

### CLI

You can use the `rpmfile-unix` package as a command line utility to get basic information about the package, similar to `rpm -qi`.

<details>
<summary>Example</summary>

```console
$ rpmfile test_misc/hello-2.12.1-1.7.x86_64.rpm
Name        : hello                 
Version     : 2.12.1
Release     : 1.7
Architecture: x86_64
Group       : Development/Tools/Other
Size        : 185847
License     : GPL-3.0-or-later
Source RPM  : hello-2.12.1-1.7.src.rpm
Build Date  : 2022-05-30
Build Host  : reproducible
Packager    : https://bugs.opensuse.org
Vendor      : openSUSE
URL         : https://www.gnu.org/software/hello
Summary     : A Friendly Greeting Program
Description :
The GNU hello program produces a familiar, friendly greeting.  It
allows nonprogrammers to use a classic computer science tool that would
otherwise be unavailable to them.  Because it is protected by the GNU
General Public License, users are free to share and change it.

GNU hello supports many native languages.
Distribution: openSUSE Tumbleweed
```

</details>

## Documentation

See the [API references](https://ocaml.org/p/rpmfile/latest/doc/index.html).

## Contribution

The project is stable, but the library could be more complete. I look forward to your pull requests!
If you encounter a bug, then please create an [issue](https://github.com/dx3mod/rpmfile/issues).

See [HACKING.md](./HACKING.md) if you are interested in developing the project.

[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager
[Angstrom]: https://github.com/inhabitedtype/angstrom
[Eio]: https://github.com/ocaml-multicore/eio
[PackageFileFormat]: https://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html