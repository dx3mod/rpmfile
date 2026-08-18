let () =
  In_channel.with_open_bin Sys.argv.(1) @@ fun ic ->
  let metadata, payload = Rpmfile.Reader.from_channel_with_payload ic in

  let uncompressed_size =
    let open Rpmfile.View in
    find_exn ~tag:1007 ~decode:Decoder.int metadata.signature
  and count_files = Rpmfile.View.sizes metadata |> List.length in

  let archive_in_stream =
    Rpmfile.Payload.to_string payload
    |> Zstd.decompress uncompressed_size
    |> Bytream.In.of_string
  in

  Rpmfile_cpio.Reader.input_entries_seq archive_in_stream count_files
  |> Seq.iter @@ fun Rpmfile_cpio.File_entry.{ filename; _ } ->
     print_endline filename
