module In = Bytream.In

type error =
  | Invalid_rpm_code
  | Illegal_rpm_version
  | Illegal_rpm_metadata_type
  | Invalid_header_record_code
  | Illegal_index_record_kind
  | Not_found_payload_size

exception Error of error

(***************************************************************************)
(*   COMMON                                                                *)
(***************************************************************************)

let raise_error e = raise @@ Error e

let input_null_term_string in_stream =
  let string = In.input_while (( <> ) '\x00') in_stream in
  In.consume_bytes in_stream 1 (* \x00 *);
  string

(***************************************************************************)
(*   LEAD SECTION                                                          *)
(***************************************************************************)

let input_metadata_code in_stream =
  match In.input_string in_stream 4 with
  | "\xED\xAB\xEE\xDB" -> ()
  | _ -> raise_error Invalid_rpm_code

and input_version in_stream =
  match In.input_int16_be in_stream with
  | 0x0300 -> `V3
  | 0x0400 -> `V4
  | _ -> raise_error Illegal_rpm_version

and input_metadata_type in_stream =
  match In.input_int16_be in_stream with
  | 0 -> `Binary
  | 1 -> `Source
  | _ -> raise_error Illegal_rpm_metadata_type

let input_lead in_stream =
  input_metadata_code in_stream;
  let version = input_version in_stream in
  let kind = input_metadata_type in_stream in
  let arch_num = In.input_int16_be in_stream in
  let name = In.input_while' ~max_len:66 (( <> ) '\x00') in_stream in
  let os_num = In.input_int16_be in_stream in
  let signature_type = In.input_int16_be in_stream in

  In.consume_bytes in_stream 16 (* padding *);

  Metadata.Lead.{ version; kind; arch_num; name; os_num; signature_type }

(***************************************************************************)
(*   HEADER STRUCTURE                                                      *)
(***************************************************************************)

let input_int in_stream = In.input_int32_be in_stream |> Int32.to_int

let input_header_record_code in_stream =
  match In.input_string in_stream 4 with
  | "\x8E\xaD\xE8\x01" -> ()
  | _ -> raise_error Invalid_header_record_code

let input_header_record in_stream =
  input_header_record_code in_stream;
  In.consume_bytes in_stream 4 (* reserved *);

  let nindex = input_int in_stream in
  let section_size = input_int in_stream in

  (~nindex, ~section_size)

type header_index_record = { tag : int; kind : int; offset : int; count : int }

let input_index_header in_stream =
  let tag = input_int in_stream in
  let kind = input_int in_stream in
  let offset = input_int in_stream in
  let count = input_int in_stream in

  { tag; kind; offset; count }

let input_index_records in_stream nindex =
  List.init nindex (fun _ -> input_index_header in_stream)
  (* NOTE: performance issue *)
  |> List.sort (fun ir ir' -> compare ir.offset ir'.offset)

let input_index_value_of_record in_stream index_record =
  let input_value in_stream =
    match index_record.kind with
    | 0 -> Metadata.Header_structure.Null
    | 1 -> Metadata.Header_structure.Char (In.input_char in_stream)
    | 2 -> Metadata.Header_structure.Int (In.input_int8 in_stream)
    | 3 -> Metadata.Header_structure.Int (In.input_int16_be in_stream)
    | 4 -> Metadata.Header_structure.Int32 (In.input_int32_be in_stream)
    | 5 -> Metadata.Header_structure.Int64 (In.input_int64_be in_stream)
    | 6 -> Metadata.Header_structure.String (input_null_term_string in_stream)
    | 7 ->
        Metadata.Header_structure.Binary
          (In.input_string in_stream index_record.count)
    | 8 | 9 ->
        Metadata.Header_structure.StringArray
          In.(take index_record.count input_null_term_string in_stream)
    | _ -> raise_error Illegal_index_record_kind
  in

  match index_record.kind with
  | 7 | 8 | 9 -> input_value in_stream
  | _ when index_record.count > 1 ->
      Metadata.Header_structure.Array
        In.(take index_record.count input_value in_stream)
  | _ -> input_value in_stream

let input_header_structure ~padding in_stream =
  let ~nindex, ~section_size = input_header_record in_stream in
  let index_records = input_index_records in_stream nindex in

  let section_offset = In.position in_stream in

  let entries = Hashtbl.create List.(length index_records) in

  let input_entry index_record =
    let absolute_offset = In.position in_stream in
    let relative_offset = absolute_offset - section_offset in

    In.consume_bytes in_stream (index_record.offset - relative_offset);

    Hashtbl.add entries index_record.tag
      (input_index_value_of_record in_stream index_record)
  in

  List.iter input_entry index_records;

  (* It's necessary for between Signature header structure and Header header structure. *)
  if padding then begin
    In.consume_bytes in_stream @@ ((8 - (section_size mod 8)) mod 8)
  end;

  entries

(***************************************************************************)
(*   Metadata                                                              *)
(***************************************************************************)

let find_payload_size_tag entries =
  match Hashtbl.find entries 1000 with
  | Metadata.Header_structure.Int32 size -> Int32.to_int size
  | (exception Not_found) | _ -> raise_error Not_found_payload_size

let input_metadata_with in_stream f =
  let lead = input_lead in_stream in
  let signature = input_header_structure ~padding:true in_stream in
  let header, header_size =
    In.with_size (input_header_structure ~padding:false) in_stream
  in

  let payload_size =
    (* RPMTAG_SIZE = Header + Payload => 
       PAYLOAD =  RPMTAG_SIZE - Header *)
    find_payload_size_tag signature - header_size
  in

  let metadata = Metadata.{ lead; signature; header } in

  f metadata payload_size

let input_metadata_only in_stream = input_metadata_with in_stream Fun.const

let input_package_without_payload in_stream =
  input_metadata_with in_stream @@ fun metadata payload_size ->
  In.consume_bytes in_stream payload_size;
  metadata

let input_metadata_with_string_payload in_stream =
  input_metadata_with in_stream @@ fun metadata payload_size ->
  (metadata, In.input_string in_stream payload_size)

let input_metadata_with_bigstring_payload in_stream =
  input_metadata_with in_stream @@ fun metadata payload_size ->
  let buffer = Bstr.create payload_size in
  In.really_input in_stream buffer 0 payload_size;
  (metadata, buffer)

(***************************************************************************)
(*   Reader utils                                                               *)
(***************************************************************************)

let from_channel_without_payload ic =
  let in_stream = Bytream.In.of_channel ic in
  input_package_without_payload in_stream

and from_channel_with_payload ic =
  let in_stream = Bytream.In.of_channel ic in
  input_metadata_with_bigstring_payload in_stream
  |> Pair.map_snd (fun payload_bigstring -> `Bigstring payload_bigstring)
