open Rpmfile

let package_path = "../../test_misc/hello-2.12.1-1.7.x86_64.rpm"

let test_name metadata () =
  Alcotest.(check string) "name" "hello" (Rpmfile.name metadata)

let test_version metadata () =
  Alcotest.(check @@ pair int int) "lead version" (3, 0) metadata.lead.version

let test_filenames metadata () =
  let non_empty_string =
    Alcotest.testable
      Fmt.(list string)
      (fun _ -> List.for_all (fun s -> s <> ""))
  in

  Alcotest.(check non_empty_string)
    "non empty string array" []
    (Rpmfile.filenames metadata)

let test_not_found_filenames metadata () =
  Alcotest.check_raises "non found filenames" (Rpmfile.Not_found "base_names")
    (fun _ -> Rpmfile.filenames metadata |> ignore)

let test_provide_names metadata () =
  Alcotest.(check @@ list string)
    "names"
    [ "hello"; "hello(x86-64)"; "mailreader" ]
    (Rpmfile.provide_names metadata)

let cases_all_selector metadata =
  let open Alcotest in
  [
    test_case "name" `Quick (test_name metadata);
    test_case "version" `Quick (test_version metadata);
    test_case "filenames" `Quick (test_filenames metadata);
    test_case "provide_names" `Quick (test_provide_names metadata);
  ]

let cases_base_selector metadata =
  let open Alcotest in
  [
    test_case "name" `Quick (test_name metadata);
    test_case "version" `Quick (test_version metadata);
    test_case "filenames" `Quick (test_not_found_filenames metadata);
  ]
