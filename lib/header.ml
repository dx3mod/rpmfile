type record = { number_of_index : int; section_size : int }
and index_record = { tag : int; kind : int; offset : int; count : int }

and index_value =
  | Null
  | Char of char
  | Int of int
  | Int32 of int32
  | Int64 of int64
  | String of string
  | Binary of Bigstringaf.t
  | StringArray of string list
  | Array of index_value list

let any_int = Angstrom.(BE.any_int32 >>| Int32.to_int)

let header_record_parser =
  let open Angstrom in
  let* _ =
    string "\x8E\xaD\xE8\x01" <|> fail "invalid header section magic number"
  in
  let* _ = advance 4 in
  let* number_of_index = any_int in
  let* section_size = any_int in

  return { number_of_index; section_size }

let index_value_parser ~section_offset index_record =
  let open Angstrom in
  let open Angstrom.BE in
  let* _ =
    let* absolute_offset = pos in
    let relative_offset = absolute_offset - section_offset in
    advance (index_record.offset - relative_offset)
  in

  let null_term_string_parser = take_till (fun c -> c = '\x00') <* advance 1 in

  let value_parser =
    match index_record.kind with
    | 0 -> return Null
    | 1 -> any_char >>| fun x -> Char x
    | 2 -> any_int8 >>| fun x -> Int x
    | 3 -> any_int16 >>| fun x -> Int x
    | 4 -> any_int32 >>| fun x -> Int32 x
    | 5 -> any_int64 >>| fun x -> Int64 x
    | 6 -> null_term_string_parser >>| fun x -> String x
    | 7 -> take_bigstring index_record.count >>| fun x -> Binary x
    | 8 | 9 ->
        count index_record.count null_term_string_parser >>| fun x ->
        StringArray x
    | kind -> fail @@ Printf.sprintf "invalid index record type: %d" kind
  in

  match index_record.kind with
  | 7 | 8 | 9 -> value_parser
  | _ when index_record.count > 1 ->
      count index_record.count value_parser >>| fun x -> Array x
  | _ -> value_parser

let parser ~selector =
  let open Angstrom in
  let* header_record = header_record_parser in

  let* index_records =
    let count n =
      let rec loop = function
        | 0 -> return []
        | n ->
            let* tag = any_int in
            if selector tag then
              let* kind = any_int in
              let* offset = any_int in
              let* count = any_int in

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
         (fun k -> index_value_parser ~section_offset k >>| fun v -> (k.tag, v))
         index_records
  in

  (* padding *)
  let* _ = advance ((8 - (header_record.section_size mod 8)) mod 8) in

  return entries
