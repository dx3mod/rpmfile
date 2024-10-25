open Lwt.Syntax

module Rpm_pkg_reader_lwt = struct
  let of_channel ic =
    let module P = Rpmfile_unix.Reader.P (Rpmfile.Selector.All) in
    let+ result = Angstrom_lwt_unix.parse P.metadata_parser ic in

    match result with _, Ok result -> result | _, Error msg -> failwith msg

  let of_file path = Lwt_io.with_file ~mode:Input path of_channel
end

let () =
  Lwt_main.run
  @@
  let* pkg = Rpm_pkg_reader_lwt.of_file Sys.argv.(1) in
  Lwt_io.printf "Name : %s\n" (Rpmfile.name pkg)
