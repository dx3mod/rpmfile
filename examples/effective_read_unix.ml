module Rpm_pkg_reader = Rpmfile.Reader.Default

let () =
  let pkg =
    In_channel.with_open_bin Sys.argv.(1)
    @@ Angstrom_unix.parse Rpm_pkg_reader.package_parser
    |> snd |> Result.get_ok
  in
  Printf.printf "Package name: %s\n" @@ Rpmfile.View.name pkg
