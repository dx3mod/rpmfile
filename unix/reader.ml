module type S = sig
  val of_string : string -> (Rpmfile.metadata, string) result
  val of_channel : in_channel -> (Rpmfile.metadata, string) result
  val of_file : string -> (Rpmfile.metadata, string) result
end

(** Metadata Angstrom's parser.  *)
module P (S : Rpmfile.Selector.S) = struct
  open Rpmfile
  open Parsers

  let metadata_parser =
    let open Angstrom in
    let* lead = lead_parser in
    let* signature = header_parser ~selector:S.select_signature_tag in
    let* header = header_parser ~selector:S.select_header_tag in

    return { lead; signature; header }
end

module Make (Selector : Rpmfile.Selector.S) : S = struct
  let of_string =
    let module P = P (Selector) in
    Angstrom.(parse_string ~consume:Consume.Prefix) P.metadata_parser

  let of_channel ic =
    let module P = P (Selector) in
    In_channel.input_all ic
    |> Angstrom.(
         Angstrom.parse_string ~consume:Consume.Prefix P.metadata_parser)

  let of_file path = In_channel.with_open_bin path of_channel
end
