(** The module for generic work with RPM package's payload. *)

type t =
  [ `String of string
  | `Bigstring of Bytream.In.buffer
  | `In_stream of Bytream.In.t ]

let to_string = function
  | `Bigstring buff -> Bstr.to_string buff
  | `String str -> str
  | `In_stream in_stream -> Bytream.In.input_while Fun.(const true) in_stream
