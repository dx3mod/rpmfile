let () =
  let pkg =
    In_channel.with_open_bin Sys.argv.(1) Rpmfile.Reader.of_channel
    |> Result.get_ok
  in

  Printf.printf "Project name: %s\n" @@ Rpmfile.View.name pkg
