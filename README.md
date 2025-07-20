# Rpmfile

A library for reading [RPM packages][RPM] (supports version 3.0 and partially 4.0) 
powered by [Angstrom].

In active development now! Reborn the project.

## Usage

You can install the package using the OPAM package manager from the repository
```console
$ opam install rpmfile
```
or pin the latest development version from GitHub.
```console
$ opam pin https://github.com/dx3mod/rpmfile.git
```

Now that the package has been installed on your system, we can start writing code using the Rpmfile library. To do this, you need to include the library in your Dune project or another way.
```dune
(libraries ... rpmfile)
```

If you do everything correctly, you will have access to the `Rpmfile` module, where you can find the `Reader` module and others. To read RPM packages, you should create an instance of the `Reader` module with defined selectors (a mechanism for parsing only the necessary tags).

Out of the box, the library has a default reader that reads all tags, but without the body.
```ocaml
module Rpm_pkg_reader = Rpmfile.Reader.Default
(* equivalents *)
module Rpm_pkg_reader = Rpmfile.Reader.Make (Rpmfile.Selector.Default)
```

Now we have a module at our disposal that provides a "bare-bones" Angstrom parser and simple functions for file parsing.
```ocaml
let hello_pkg = 
  In_channel.with_open_bin "hello.rpm" Rpm_pkg_reader.of_channel 
  |> Result.get_ok
in (* ... *)
```

After successful parsing, we got a `Package.t` type record. To extract tags from it, we use the `View` module.
```ocaml
# Rpmfile.View.name hello_pkg;;
- : string = "hello"

# Rpmfile.View.build_time hello_pkg;;
- : int = 1653906083
```

## Contribution

See [HACKING.md](./HACKING.md) if you are interested in developing the project.

[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager
[Angstrom]: https://github.com/inhabitedtype/angstrom