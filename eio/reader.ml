module type S = sig
  val of_flow :
    ?initial_size:int ->
    max_size:int ->
    _ Eio.Flow.source ->
    (Rpmfile.metadata, string) Stdlib.result
end

module Make (S : Rpmfile.Selector.S) : S = struct
  let of_flow ?(initial_size = 3_000) ~max_size flow =
    let buf = Eio.Buf_read.of_flow flow ~initial_size ~max_size in
    let parser =
      Parsers.metadata_parser ~select_signature_tag:S.select_signature_tag
        ~select_header_tag:S.select_header_tag
    in

    Eio.Buf_read.format_errors parser buf
    |> Result.map_error (function `Msg m -> m)
end
