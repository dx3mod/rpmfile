open Rpmfile

let test_name metadata () =
  Alcotest.(check string) "name" "hello" (Rpmfile.name metadata)

let test_version metadata () =
  Alcotest.(check @@ pair int int) "lead version" (3, 0) metadata.lead.version

let test_array_string metadata () =
  let non_empty_string =
    Alcotest.testable
      Fmt.(list string)
      (fun _ -> List.for_all (fun s -> s <> ""))
  in

  Alcotest.(check non_empty_string)
    "non empty string array" []
    (Rpmfile.filenames metadata)

let test_not_found metadata () =
  Alcotest.check_raises "non found filenames" (Rpmfile.Not_found "base_names")
    (fun _ -> Rpmfile.filenames metadata |> ignore)
