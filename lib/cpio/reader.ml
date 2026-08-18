module In = Bytream.In

exception Not_supported_format

let input_magic in_stream =
  match In.input_string in_stream 6 with
  | "070701" -> ()
  | _ -> raise Not_supported_format

let input_filename ~max_len in_stream =
  let contents = In.input_while ~max_len (( <> ) '\x00') in_stream in
  In.consume_bytes in_stream 1 (* \x00 *);
  contents

let input_padding in_stream =
  In.consume_bytes in_stream ((4 - (In.position in_stream mod 4)) mod 4)

let input_field in_stream = In.input_string in_stream 8

let input_int_field in_stream =
  input_field in_stream |> ( ^ ) "0x" |> int_of_string

let input_header in_stream =
  input_magic in_stream;

  let inode_number = input_int_field in_stream in
  let permission_bits = input_int_field in_stream in
  let user_id = input_int_field in_stream in
  let group_id = input_int_field in_stream in
  let nlink = input_int_field in_stream in
  let modification_time = input_int_field in_stream in
  let file_size = input_int_field in_stream in
  let major_device_number = input_int_field in_stream in
  let minor_device_number = input_int_field in_stream in
  let major_raw_device_number = input_int_field in_stream in
  let minor_raw_device_number = input_int_field in_stream in
  let name_size = input_int_field in_stream in
  let checksum = input_int_field in_stream in

  Header.
    {
      inode_number;
      permission_bits;
      user_id;
      group_id;
      nlink;
      modification_time;
      file_size;
      major_device_number;
      minor_device_number;
      major_raw_device_number;
      minor_raw_device_number;
      name_size;
      checksum;
    }

let input_entry_with ~input_payload in_stream =
  let header = input_header in_stream in
  let filename = input_filename ~max_len:header.name_size in_stream in
  input_padding in_stream;
  let contents = input_payload in_stream header.file_size in
  input_padding in_stream;

  File_entry.{ metadata = header; filename; contents }

let input_entry_without_payload in_stream =
  let input_payload in_stream size =
    In.consume_bytes in_stream size;
    None
  in
  input_entry_with ~input_payload in_stream

let input_payload_string in_stream size =
  Option.some @@ `String (In.input_string in_stream size)

let input_entry in_stream =
  input_entry_with ~input_payload:input_payload_string in_stream

let input_entries_with ~input_payload in_stream n =
  In.take n (input_entry_with ~input_payload) in_stream

and input_entries_seq_with ~input_payload in_stream n =
  Seq.init n @@ fun _ -> input_entry_with ~input_payload in_stream

let input_entries_without_payloads in_stream n =
  let input_payload in_stream size =
    In.consume_bytes in_stream size;
    None
  in
  input_entries_with ~input_payload in_stream n

let input_entries in_stream n =
  input_entries_with ~input_payload:input_payload_string in_stream n

let input_entries_seq in_stream n =
  input_entries_seq_with ~input_payload:input_payload_string in_stream n
