module Rpm_reader = Rpmfile.Reader (Rpmfile.Selector.Base)

let metadata = Rpm_reader.of_file_exn "hello-2.12.1-1.7.x86_64.rpm"

let test_name () =
  Alcotest.(check string) "name" "hello" (Rpmfile.name metadata)

let test_version () =
  Alcotest.(check @@ pair int int) "lead version" (3, 0) metadata.lead.version

let test_not_found () =
  Alcotest.check_raises "non found filenames" (Rpmfile.Not_found "base_names")
    (fun _ -> Rpmfile.filenames metadata |> ignore)

let () =
  let open Alcotest in
  run "Rpmfile (Selector.Base)"
    [
      ( "hello-2.12.1-1.7.x86_64.rpm",
        [
          test_case "name" `Quick test_name;
          test_case "version" `Quick test_version;
          test_case "filenames" `Quick test_not_found;
        ] );
    ]
