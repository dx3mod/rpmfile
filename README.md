<img src="https://i.ibb.co/LXxS8DP1/rpmfile-logo-001.png" alt="text" width="150">

# Rpmfile

A pure OCaml library for parsing RPM files (supports V3 and partly V4 package versions).

[**API references**](https://ocaml.org/packages/rpmfile/latest/docs)

## Quick start

You can install the `rpmfile` library using the [OPAM] package manager or any other method you prefer.

```console
$ opam install rpmfile.1.0.0
```

You can also get the latest version of the upstream (developer) branch.
```console
$ opam pin rpmfile.dev https://github.com/dx3mod/rpmfile.git
```

If you are using [Dune], please add the `rpmfile` library to your dependencies.


### Theoretical minimum about RPM files

Each [RPM package](https://en.wikipedia.org/wiki/RPM_Package_Manager) consists of four sections: `Lead`, `Signature`, `Header`, and `Payload`. The first three are meta information about the package. It contains a description, a dependency list, and so on.
 
The information in the `Signature` and `Header` sections is stored on a key-value basis, where the key is called a tag. The value can be a number, a string or an array. The `Payload` section usually contains a compressed [Cpio] archive that already contains the package's files.

For more information, please see [the materials](./CONTRIBUTING.md).

### In use

Below is an example of simply reading an RPM file and obtaining the package name and version.
```ocaml
let () = 
  let metadata = 
    In_channel.with_open_bin 
      "hello.rpm" 
      Rpmfile.Reader.from_channel_without_payload 
  in

  let name, release = Rpmfile.View.(name metadata, release metadata) in 
  Printf.printf "%s.%s\n" name release
  (* hello.1.3 *)
```

For more details, see [API references](https://ocaml.org/p/rpmfile/latest/doc/index.html) and [`examples/`](./examples/) directory.

## References

Package format specification:
- [Package File Format](https://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html)
- [V4 Package format](https://rpm-software-management.github.io/rpm/manual/format_v4.html)
- [RPM Tags](https://rpm-software-management.github.io/rpm/manual/tags.html)

Reference implementations in other languages:
- <https://github.com/rpm-rs/rpm/> written in Rust

## License

The project is licensed under [the MIT License](./LICENSE), which allows for all permissions.
Just use it and enjoy yourself without fear. We are always open to pull requests!


[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager
[OPAM]: https://opam.ocaml.org/
[Dune]: https://dune.build
[Cpio]: https://en.wikipedia.org/wiki/Cpio