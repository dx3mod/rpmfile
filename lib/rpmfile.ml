(** A library for reading RPM packages (supports version 3.0 and partially 4.0)
    powered by Angstrom.

    {[
      module Rpm_pkg_reader = Rpmfile.Reader.Default

      let () =
        let pkg =
          In_channel.with_open_bin Sys.argv.(1) Rpm_pkg_reader.of_channel
          |> Result.get_ok
        in
        Printf.printf "Package name: %s\n" @@ Rpmfile.View.name pkg
    ]} *)

module Package = Package
module Reader = Reader
module View = View
