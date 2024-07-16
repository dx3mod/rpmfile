type lead = Lead.t

type header = (tag * value) list
and tag = int
and value = Header.index_value

type metadata = { lead : lead; signature : header; header : header }

(* Parser *)
module P = struct
  let metadata_parser =
    let open Angstrom in
    let* lead = Lead.parser in
    let* signature = Header.parser in
    let* header = Header.parser in

    return { lead; signature; header }
end

module Reader = struct
  type result = (metadata, string) Stdlib.result

  let of_string =
    Angstrom.(parse_string ~consume:Consume.Prefix) P.metadata_parser

  let of_file path =
    In_channel.with_open_bin path (fun ic ->
        In_channel.input_all ic |> of_string)
end
