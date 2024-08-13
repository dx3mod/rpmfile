module Rpm_reader = Rpmfile_eio.Reader.Make (Rpmfile.Selector.All)

let metadata =
  Eio_main.run (fun env ->
      let path = Eio.Path.(env#fs / Test_cases.package_path) in
      Eio.Path.with_open_in path (Rpm_reader.of_flow ~max_size:10_000))

let () =
  let open Alcotest in
  run "Rpmfile_eio (Selector.All)"
    [ ("hello-2.12.1-1.7.x86_64.rpm", Test_cases.cases_all_selector metadata) ]
