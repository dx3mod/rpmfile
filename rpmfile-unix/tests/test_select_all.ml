module Rpm_reader = Rpmfile_unix.Reader.Make (Rpmfile.Selector.All)

let metadata = Rpm_reader.of_file Test_cases.package_path |> Unwrap.unwrap

let () =
  let open Alcotest in
  run "Rpmfile_unix (Selector.All)"
    [ ("hello-2.12.1-1.7.x86_64.rpm", Test_cases.cases_all_selector metadata) ]
