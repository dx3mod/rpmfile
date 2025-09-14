let () =
  let rpm_file_path, extracted_file_path = (Sys.argv.(1), Sys.argv.(2)) in

  let pkg =
    In_channel.with_open_bin rpm_file_path
    @@ Fun.compose
         (Rpmfile.Reader.of_string ~capture_payload:true)
         In_channel.input_all
    |> Result.get_ok
  in

  Out_channel.with_open_bin extracted_file_path (fun oc ->
      Out_channel.output_string oc @@ Option.get pkg.payload)
