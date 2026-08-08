module In = Bytream.In

type error =
  | Invalid_rpm_code
  | Illegal_rpm_version
  | Illegal_rpm_package_type
  | Invalid_header_record_code
  | Illegal_index_record_kind
  | Not_found_payload_size

exception Error of error

let raise_error e = raise @@ Error e

(***************************************************************************)
(*   LEAD SECTION                                                          *)
(***************************************************************************)

let input_package_code in_stream =
  match In.input_string in_stream 4 with
  | "\xED\xAB\xEE\xDB" -> ()
  | _ -> raise_error Invalid_rpm_code

and input_version in_stream =
  match In.input_int16_be in_stream with
  | 0x0300 -> `V3
  | 0x0400 -> `V4
  | _ -> raise_error Illegal_rpm_version

and input_package_type in_stream =
  match In.input_int16_be in_stream with
  | 0 -> `Binary
  | 1 -> `Source
  | _ -> raise_error Illegal_rpm_package_type

let input_lead in_stream =
  input_package_code in_stream;
  let version = input_version in_stream in
  let kind = input_package_type in_stream in
  let arch_num = In.input_int16_be in_stream in
  let name = In.input_while' ~max:65 (( <> ) '\x00') in_stream in
  let os_num = In.input_int16_be in_stream in
  let signature_type = In.input_int16_be in_stream in

  In.consume_bytes in_stream 16 (* padding *);

  Package_intf.{ version; kind; arch_num; name; os_num; signature_type }

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
  let input_cstring in_stream = In.input_while (( <> ) '\x00') in_stream in

  let input_value in_stream =
    match index_record.kind with
    | 0 -> Package_intf.Null
    | 1 -> Package_intf.Char (In.input_char in_stream)
    | 2 -> Package_intf.Int (In.input_int8 in_stream)
    | 3 -> Package_intf.Int (In.input_int16_be in_stream)
    | 4 -> Package_intf.Int32 (In.input_int32_be in_stream)
    | 5 -> Package_intf.Int64 (In.input_int64_be in_stream)
    | 6 -> Package_intf.String (input_cstring in_stream)
    | 7 -> Package_intf.Binary (In.input_string in_stream index_record.count)
    | 8 | 9 ->
        Package_intf.StringArray
          (List.init index_record.count @@ fun _ -> input_cstring in_stream)
    | _ -> raise_error Illegal_index_record_kind
  in

  match index_record.kind with
  | 7 | 8 | 9 -> input_value in_stream
  | _ when index_record.count > 1 ->
      Package_intf.Array
        (List.init index_record.count @@ fun _ -> input_value in_stream)
  | _ -> input_value in_stream

let input_header_structure ~padding in_stream =
  let ~nindex, ~section_size = input_header_record in_stream in
  let index_records = input_index_records in_stream nindex in

  let section_offset = In.position in_stream in

  let input_entry index_record =
    let absolute_offset = In.position in_stream in
    let relative_offset = absolute_offset - section_offset in

    In.consume_bytes in_stream (index_record.offset - relative_offset);

    (index_record.tag, input_index_value_of_record in_stream index_record)
  in

  let entries = List.map input_entry index_records in

  (* It's necessary for between Signature header structure and Header header structure. *)
  if padding then begin
    In.consume_bytes in_stream @@ ((8 - (section_size mod 8)) mod 8)
  end;

  let structure_size = section_size + (16 * List.length index_records) + 16 in

  (entries, structure_size)

(***************************************************************************)
(*   PACKAGE                                                               *)
(***************************************************************************)

let find_payload_size_tag entries =
  match List.assoc 1000 entries with
  | Package_intf.Int32 size -> Int32.to_int size
  | (exception Not_found) | _ -> raise_error Not_found_payload_size

let input_package_with ~on_payload in_stream =
  let lead = input_lead in_stream in
  let signature, _ = input_header_structure ~padding:true in_stream in
  let header, structure_size =
    input_header_structure ~padding:false in_stream
  in

  let payload_size =
    (* RPMTAG_SIZE = Header + Payload => 
       PAYLOAD =  RPMTAG_SIZE - Header *)
    find_payload_size_tag signature - structure_size
  in

  on_payload in_stream payload_size;

  Package_intf.{ lead; signature; header }

let input_package_meta_only in_stream =
  let on_payload _ _ = () in
  input_package_with ~on_payload in_stream

let input_package_without_payload in_stream =
  let on_payload in_stream size = In.consume_bytes in_stream size in
  input_package_with ~on_payload in_stream

let input_package_with_payload in_stream =
  let payload = ref "" in

  let on_payload in_stream size = payload := In.input_string in_stream size in
  let package = input_package_with ~on_payload in_stream in

  (package, !payload)
