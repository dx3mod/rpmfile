module Rpm_reader = Rpmfile.Reader (Rpmfile.Selector.All)

let metadata = Rpm_reader.of_file_exn "hello-2.12.1-1.7.x86_64.rpm"

let test_name () =
  Alcotest.(check string) "name" "hello" (Rpmfile.name metadata)

let test_version () =
  Alcotest.(check @@ pair int int) "lead version" (3, 0) metadata.lead.version

let test_array_string () =
  let non_empty_string =
    Alcotest.testable
      Fmt.(list string)
      (fun _ -> List.for_all (fun s -> s <> ""))
  in

  Alcotest.(check non_empty_string)
    "non empty string array" []
    (Rpmfile.filenames metadata)

let () =
  let open Alcotest in
  run "Rpmfile"
    [
      ( "hello-2.12.1-1.7.x86_64.rpm",
        [
          test_case "name" `Quick test_name;
          test_case "version" `Quick test_version;
          test_case "filenames" `Quick test_array_string;
        ] );
    ]
