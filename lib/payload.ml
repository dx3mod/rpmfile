(** The module for work with RPM package's payload. *)

type t =
  int * [ `Bigstring of Bstr.t | `Stream of Bytream.In.t | `String of string ]

let of_incoming_bytes size in_stream = (size, `Stream in_stream)
and of_bigstring buffer = (Bstr.length buffer, `Bigstring buffer)
and of_string string = (String.length string, `String string)

let to_string (length, source) =
  match source with
  | `Stream in_stream -> Bytream.In.input_string in_stream length
  | `Bigstring buffer -> Bstr.to_string buffer
  | `String string -> string

and to_incoming_bytes (_, source) =
  match source with
  | `Bigstring buffer -> Bytream.In.of_buffer buffer
  | `String string -> Bytream.In.of_string string
  | `Stream in_stream -> in_stream
