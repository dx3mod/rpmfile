(** The module for generic work with RPM package's payload. *)

type t =
  [ `String of string
  | `Bigstring of Bytream.In.buffer
  | `In_stream of Bytream.In.t
  | `Out_stream of Bytream.Out.t ]
