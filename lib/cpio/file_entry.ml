(** A file record of archive. *)

type t = { metadata : Header.t; filename : string; contents : contents }
and t_with_string_payload = t
and t_with_bigstring_payload = t
and t_without_payload = t
and contents = [ `String of string | `Bigstring of string ] option
