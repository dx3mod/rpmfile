let () =
  In_channel.with_open_bin Sys.argv.(1) @@ fun ic ->
  let in_stream = Bytream.In.of_channel ic in
  let metadata = Rpmfile.Reader.input_package_without_payload in_stream in

  Printf.printf "Package name : %S\n" Rpmfile.View.(name metadata);
  Printf.printf "Package release : %s\n" Rpmfile.View.(release metadata);
  Printf.printf "Package summery : %S\n"
    Rpmfile.View.(summery metadata |> List.hd)
