# Rpmfile

A library for reading and writing [RPM packages][RPM] (supports version 3.0 and partially 4.0) written in OCaml.

## Example: get a package name

```ocaml
let pkg = In_channel.with_open_bin "hello.rmp" 
          Rpmfile.Reader.of_channel_exn 
in Rpmfile.View.name pkg
```

## Contribution

See [HACKING.md](./HACKING.md) if you are interested in developing the project.

[RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager