(** A RPM(v3) package metadata parser powered by Angstrom. *)

open Types

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

module Selector = Selector
module Tag = Tag
module Accessor = Accessor

let name = Accessor.(get_by_header_tag string Tag.Header.name)
let build_time = Accessor.(get_by_header_tag any_int Tag.Header.build_time)
let build_host = Accessor.(get_by_header_tag string Tag.Header.build_host)
let size = Accessor.(get_by_header_tag any_int Tag.Header.size)

let description =
  Accessor.(get_by_header_tag (List.hd << string_array) Tag.Header.description)

let summary =
  Accessor.(get_by_header_tag (List.hd << string_array) Tag.Header.summary)

let license = Accessor.(get_by_header_tag string Tag.Header.license)
let os = Accessor.(get_by_header_tag string Tag.Header.os)
let arch = Accessor.(get_by_header_tag string Tag.Header.arch)
let vendor = Accessor.(get_by_header_tag string Tag.Header.vendor)
let packager = Accessor.(get_by_header_tag string Tag.Header.packager)
let group = Accessor.(get_by_header_tag string_array Tag.Header.group)
let url = Accessor.(get_by_header_tag string Tag.Header.url)
