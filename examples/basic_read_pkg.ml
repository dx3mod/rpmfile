module Rpm_pkg_reader = Rpmfile.Reader.Default

let () =
  let pkg =
    In_channel.with_open_bin Sys.argv.(1) Rpm_pkg_reader.of_channel
    |> Result.get_ok
  in
  Printf.printf "Package name: %s\n" @@ Rpmfile.View.name pkg
