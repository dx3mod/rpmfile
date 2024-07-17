module Rpm_reader = Rpmfile.Reader (Rpmfile.Selector.All)

let metadata = Rpm_reader.of_file_exn "hello-2.12.1-1.7.x86_64.rpm"

let test_name () =
  Alcotest.(check string) "name" "hello" (Rpmfile.name metadata)

let test_version () =
  Alcotest.(check @@ pair int int) "lead version" (3, 0) metadata.lead.version

let () =
  let open Alcotest in
  run "Rpmfile"
    [
      ( "hello-2.12.1-1.7.x86_64.rpm",
        [
          test_case "name" `Quick test_name;
          test_case "version" `Quick test_version;
        ] );
    ]
