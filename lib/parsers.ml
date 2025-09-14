open Angstrom

(***************************************************************************)
(*      HELPERS                                                            *)
(***************************************************************************)

let cstring = take_till (fun c -> c = '\x00') <* advance 1
let any_int32_to_int = BE.any_int32 >>| Int32.to_int

(***************************************************************************)
(*      LEAD SECTION PARSER                                                *)
(***************************************************************************)

let lead =
  let+ _ =
    string "\xED\xAB\xEE\xDB" <|> fail "invalid magic number of LEAD section"
  and+ version =
    BE.any_int16 >>| function
    | 0x0300 -> `V3
    | 0x0400 -> `V4
    | _ -> raise (Invalid_argument "lead version")
  and+ kind =
    BE.any_int16 >>| function
    | 0 -> `Binary
    | 1 -> `Source
    | _ -> raise (Invalid_argument "lead kind (binary or source)")
  and+ arch_num = BE.any_int16
  and+ name =
    let* name = take_till (fun c -> c = '\x00') in
    assert (String.length name < 66);
    let+ _ = advance (66 - String.length name) in
    name
  and+ os_num = BE.any_int16
  and+ signature_type = BE.any_int16
  and+ _ = advance 16 in

  Package.{ version; kind; arch_num; name; os_num; signature_type }

(***************************************************************************)
(*      HEADER STRUCTURE                                                   *)
(***************************************************************************)

module Header_structure = struct
  type header_record = {
    nindex : int;
        (** The number of Index Records that follow this Header Record. There
            should be at least 1 Index Record. *)
    section_size : int;
        (** The size in bytes of the storage area for the data pointed to by the
            Index Records. *)
  }

  and index_record = { tag : int; kind : int; offset : int; count : int }

  let header_record =
    let+ _ =
      string "\x8E\xaD\xE8\x01"
      <|> fail "invalid magic number of HEADER section "
    and+ _ = advance 4
    and+ nindex = any_int32_to_int
    and+ section_size = any_int32_to_int in

    { nindex; section_size }

  let index_value index_record =
    let open Package.Header_structure in
    let value_parser =
      let open Angstrom.BE in
      match index_record.kind with
      | 0 -> return Null
      | 1 -> any_char >>| fun x -> Char x
      | 2 -> any_uint8 >>| fun x -> Int x
      | 3 -> any_uint16 >>| fun x -> Int x
      | 4 -> any_int32 >>| fun x -> Int32 x
      | 5 -> any_int64 >>| fun x -> Int64 x
      | 6 -> cstring >>| fun x -> String x
      | 7 -> take_bigstring index_record.count >>| fun buf -> Binary buf
      | 8 | 9 -> count index_record.count cstring >>| fun x -> StringArray x
      | kind -> fail @@ Printf.sprintf "invalid index record type: %d" kind
    in
    match index_record.kind with
    | 7 | 8 | 9 -> value_parser
    | _ when index_record.count > 1 ->
        count index_record.count value_parser >>| fun x -> Array x
    | _ -> value_parser

  let index_records ~predicate_tag ~nindex =
    let count n =
      let rec loop = function
        | 0 -> return []
        | n ->
            let* tag = any_int32_to_int in
            if predicate_tag tag then
              let* kind = any_int32_to_int
              and+ offset = any_int32_to_int
              and+ count = any_int32_to_int in

              lift (List.cons { tag; kind; offset; count }) (loop @@ pred n)
            else advance 12 *> loop (pred n)
      in

      loop n
    in

    count nindex >>| List.sort (fun ka kb -> compare ka.offset kb.offset)
end

let header_structure ~predicate_tag ~padding =
  let* header_record = Header_structure.header_record in
  let* index_records =
    Header_structure.index_records ~predicate_tag ~nindex:header_record.nindex
  in

  let entries : Package.Header_structure.t Angstrom.t =
    let* header_structure_section_offset = pos in

    list
    @@ List.map
         (fun index_record ->
           let* _ =
             let* absolute_offset = pos in
             let relative_offset =
               absolute_offset - header_structure_section_offset
             in
             advance (index_record.Header_structure.offset - relative_offset)
           in

           Header_structure.index_value index_record >>| fun value ->
           (index_record.tag, value))
         index_records
  in

  let* _ =
    if padding then advance ((8 - (header_record.section_size mod 8)) mod 8)
    else return ()
  in

  entries

(***************************************************************************)
(*      SIGNATURE & HEADER                                                 *)
(***************************************************************************)

let signature = header_structure ~padding:true
and header = header_structure ~padding:false

(***************************************************************************)
(*      PACKAGE                                                            *)
(***************************************************************************)

let package ~predicate_signature_tag ~predicate_header_tag ~capture_payload =
  let+ lead = lead
  and+ signature = signature ~predicate_tag:predicate_signature_tag
  and+ header = header ~predicate_tag:predicate_header_tag
  and+ payload =
    if capture_payload then available >>= take >>| Option.some else return None
  in

  Package.{ lead; signature; header; payload }
