(** RPM package's payload type. *)

type t =
  [ `String of string
  | `Bigstring of Bytream.In.buffer
  | `In_stream of Bytream.In.t
  | `Out_stream of Bytream.Out.t ]
