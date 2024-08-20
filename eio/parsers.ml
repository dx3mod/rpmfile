open Rpmfile
open Eio.Buf_read.Syntax

module R = struct
  include Eio.Buf_read

  let count n p =
    if n < 0 then failwith "count: n < 0"
    else
      let rec loop = function
        | 0 -> return []
        | n ->
            let* value = p in
            loop @@ pred n |> map (List.cons value)
      in
      loop n

  let rec list ps =
    match ps with
    | [] -> return []
    | p :: ps ->
        let* value = p in
        list ps |> map (List.cons value)

  let int = BE.uint32 |> map Int32.to_int
end

let lead_parser =
  let+ _ = R.string "\xED\xAB\xEE\xDB"
  and+ version =
    R.BE.uint16
    |> R.map (function
         | 0x0300 -> (3, 0)
         | 0x0400 -> (4, 0)
         | _ -> failwith "invalid package version")
  and+ kind =
    R.BE.uint16
    |> R.map (function
         | 0 -> Lead.Binary
         | 1 -> Lead.Source
         | _ -> failwith "bad project_type conversion")
  and+ arch_num = R.BE.uint16
  and+ name =
    let* name = R.take_while (fun c -> c <> '\000') in
    let+ _ = R.skip (66 - String.length name) in
    name
  and+ os_num = R.BE.uint16
  and+ signature_type = R.BE.uint16
  and+ _ = R.skip 16 in

  Lead.{ version; kind; arch_num; name; os_num; signature_type }

let header_index_parser =
  let+ _ = R.string "\x8E\xaD\xE8\x01"
  and+ _ = R.skip 4
  and+ number_of_index = R.int
  and+ section_size = R.int in

  Header.{ number_of_index; section_size }

let null_term_string_parser = R.take_while (fun c -> c <> '\x00') <* R.skip 1

let header_entry_value_parser ~(section_offset : int)
    (record : Header.Entry.record) =
  let open Header.Entry in
  let ( >>| ) x f = R.map f x in

  let* _ =
    let* absolute_offset = R.consumed_bytes in
    let relative_offset = absolute_offset - section_offset in
    R.skip (record.offset - relative_offset)
  in

  let value_parser =
    match record.kind with
    | 0 -> R.return Null
    | 1 -> R.any_char >>| fun x -> Char x
    | 2 -> R.uint8 >>| fun x -> Int x
    | 3 -> R.BE.uint16 >>| fun x -> Int x
    | 4 -> R.BE.uint32 >>| fun x -> Int32 x
    | 5 -> R.BE.uint64 >>| fun x -> Int64 x
    | 6 -> null_term_string_parser >>| fun x -> String x
    | 7 -> R.take record.count >>| fun s -> Binary (Bytes.unsafe_of_string s)
    | 8 | 9 ->
        R.count record.count null_term_string_parser >>| fun x -> StringArray x
    | kind -> failwith @@ Printf.sprintf "invalid index record type: %d" kind
  in

  match record.kind with
  | 7 | 8 | 9 -> value_parser
  | _ when record.count > 1 ->
      R.count record.count value_parser >>| fun x -> Array x
  | _ -> value_parser

let header_parser ~selector =
  let open Header.Entry in
  let open Header in
  let* index = header_index_parser in
  let* records =
    let count n =
      let rec loop = function
        | 0 -> R.return []
        | n ->
            let* tag = R.int in
            if selector tag then
              let* kind = R.int in
              let* offset = R.int in
              let* count = R.int in

              loop (pred n) |> R.map (List.cons { tag; kind; offset; count })
            else R.skip 12 *> loop (pred n)
      in

      loop n
    in

    count index.number_of_index
    |> R.map (List.sort (fun ka kb -> compare ka.offset kb.offset))
  in

  let+ entries =
    let* section_offset = R.consumed_bytes in
    R.list
    @@ List.map
         (fun k ->
           header_entry_value_parser ~section_offset k
           |> R.map (fun v -> (k.tag, v)))
         records
  and+ _ = R.skip ((8 - (index.section_size mod 8)) mod 8) in

  entries

let metadata_parser ~select_header_tag ~select_signature_tag =
  let+ lead = lead_parser
  and+ signature = header_parser ~selector:select_signature_tag
  and+ header = header_parser ~selector:select_header_tag in

  { lead; signature; header }
