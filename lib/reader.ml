module Parsers = struct
  open Angstrom

  module Convert = struct
    let lead_version_of_int = function
      | 0x0300 -> `V3
      | 0x0400 -> `V4
      | _ -> raise (Invalid_argument "lead version")

    and lead_kind_of_int = function
      | 0 -> `Binary
      | 1 -> `Source
      | _ -> raise (Invalid_argument "lead kind (binary or source)")
  end

  module Utils = struct
    let cstring = take_till (fun c -> c = '\x00') <* advance 1
    let any_int32 = BE.any_int32 >>| Int32.to_int
  end

  let lead =
    let+ _ =
      string "\xED\xAB\xEE\xDB" <|> fail "invalid magic number of LEAD section"
    and+ version = BE.any_int16 >>| Convert.lead_version_of_int
    and+ kind = BE.any_int16 >>| Convert.lead_kind_of_int
    and+ arch_num = BE.any_int16
    and+ name =
      let* name = take_till (fun c -> c = '\x00') in
      (* NOTE: breake if name's lengtht > 66 *)
      let+ _ = advance (66 - String.length name) in
      name
    and+ os_num = BE.any_int16
    and+ signature_type = BE.any_int16
    and+ _ = advance 16 in

    Package.{ version; kind; arch_num; name; os_num; signature_type }

  type header_index = { number_of_index : int; section_size : int }
  and header_entry = { tag : int; kind : int; offset : int; count : int }

  let rec header ~selector =
    let* header_record = header_index in

    let* index_records =
      let count n =
        let rec loop = function
          | 0 -> return []
          | n ->
              let* tag = Utils.any_int32 in
              if selector tag then
                let* kind = Utils.any_int32
                and+ offset = Utils.any_int32
                and+ count = Utils.any_int32 in

                lift (List.cons { tag; kind; offset; count }) (loop @@ pred n)
              else advance 12 *> loop (pred n)
        in

        loop n
      in

      count header_record.number_of_index
      >>| List.sort (fun ka kb -> compare ka.offset kb.offset)
    in

    let* entries =
      let* section_offset = pos in
      list
      @@ List.map
           (fun k ->
             header_index_value ~section_offset k >>| fun v -> (k.tag, v))
           index_records
    in

    (* padding *)
    let* _ = advance ((8 - (header_record.section_size mod 8)) mod 8) in

    return entries

  and header_index =
    let+ _ =
      string "\x8E\xaD\xE8\x01"
      <|> fail "invalid magic number of HEADER section "
    and+ _ = advance 4
    and+ number_of_index = BE.any_int32 >>| Int32.to_int
    and+ section_size = BE.any_int32 >>| Int32.to_int in

    { number_of_index; section_size }

  and header_index_value ~section_offset index_record =
    let open Angstrom.BE in
    let open Package in
    let* _ =
      let* absolute_offset = pos in
      let relative_offset = absolute_offset - section_offset in
      advance (index_record.offset - relative_offset)
    in

    let value_parser =
      match index_record.kind with
      | 0 -> return Null
      | 1 -> any_char >>| fun x -> Char x
      | 2 -> any_uint8 >>| fun x -> Int x
      | 3 -> any_uint16 >>| fun x -> Int x
      | 4 -> any_int32 >>| fun x -> Int32 x
      | 5 -> any_int64 >>| fun x -> Int64 x
      | 6 -> Utils.cstring >>| fun x -> String x
      | 7 -> take_bigstring index_record.count >>| fun buf -> Binary buf
      | 8 | 9 ->
          count index_record.count Utils.cstring >>| fun x -> StringArray x
      | kind -> fail @@ Printf.sprintf "invalid index record type: %d" kind
    in

    match index_record.kind with
    | 7 | 8 | 9 -> value_parser
    | _ when index_record.count > 1 ->
        count index_record.count value_parser >>| fun x -> Array x
    | _ -> value_parser

  let package ~signature_selector ~header_selector ~select_body =
    let+ lead = lead
    and+ signature = header ~selector:signature_selector
    and+ header = header ~selector:header_selector
    and+ body =
      let open Angstrom in
      if select_body then take_bigstring_while (Fun.const true) >>| Option.some
      else (available >>= advance) *> return None
    in

    Package.{ lead; signature; header; body }
end

module Selector = struct
  module type S = sig
    val select_header_entries : Package.header_tag -> bool
    val select_signature_entries : Package.header_tag -> bool
    val select_body : bool
  end

  module Default : S = struct
    let select_header_entries = Fun.const true
    let select_signature_entries = Fun.const true
    let select_body = false
  end

  module Default_with_body : S = struct
    include Default

    let select_body = true
  end
end

module Make (Selec : Selector.S) = struct
  let package_parser =
    Parsers.package ~signature_selector:Selec.select_signature_entries
      ~header_selector:Selec.select_header_entries
      ~select_body:Selec.select_body

  let of_string = Angstrom.(parse_string ~consume:All) package_parser
  let of_bigstring = Angstrom.(parse_bigstring ~consume:All) package_parser
  let of_channel = Fun.compose of_string In_channel.input_all
end

module Default = Make (Selector.Default)

let is_package input =
  String.starts_with ~prefix:"\xED\xAB\xEE\xDB\x03\x00" input
  || String.starts_with ~prefix:"\xED\xAB\xEE\xDB\x04\x00" input
