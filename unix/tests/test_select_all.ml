module Rpm_reader = Rpmfile_unix.Reader.Make (Rpmfile.Selector.All)

let metadata =
  Rpm_reader.of_file "../../test_misc/hello-2.12.1-1.7.x86_64.rpm"
  |> Unwrap.unwrap

let () =
  let open Alcotest in
  let open Testlib in
  run "Rpmfile_unix (Selector.All)"
    [
      ( "hello-2.12.1-1.7.x86_64.rpm",
        [
          test_case "name" `Quick (test_name metadata);
          test_case "version" `Quick (test_version metadata);
          test_case "filenames" `Quick (test_array_string metadata);
        ] );
    ]
