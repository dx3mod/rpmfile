(** A RPM(v3) package metadata parser powered by Angstrom. *)

type lead = Lead.t

type header = (tag * value) list
and tag = int
and value = Header.index_value

type metadata = { lead : lead; signature : header; header : header }

module Selector = Selector

(* Parser *)
module P (Selector : Selector.S) = struct
  let metadata_parser =
    let open Angstrom in
    let* lead = Lead.parser in
    let* signature = Header.parser ~selector:Selector.select_signature_tag in
    let* header = Header.parser ~selector:Selector.select_header_tag in

    return { lead; signature; header }
end

module Reader (Selector : Selector.S) = struct
  type result = (metadata, string) Stdlib.result

  exception Error of string

  let of_string =
    let module P = P (Selector) in
    Angstrom.(parse_string ~consume:Consume.Prefix) P.metadata_parser

  let of_string_exn s =
    match of_string s with
    | Ok metadata -> metadata
    | Error msg -> raise (Error msg)

  let of_file' path of_string =
    In_channel.with_open_bin path (fun ic ->
        In_channel.input_all ic |> of_string)

  let of_file path = of_file' path of_string
  let of_file_exn path = of_file' path of_string_exn
end
