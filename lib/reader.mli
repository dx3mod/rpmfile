(** The module provides functions to read RPM packages from incoming byte
    streams. *)

(** {1 Input RPM package functions} *)

val input_metadata_only : Bytream.In.t -> Metadata.t
(** [input_metadata_only in_stream] *)

(** {2 With payload} *)

val input_metadata_with :
  on_payload:(Bytream.In.t -> int -> unit) -> Bytream.In.t -> Metadata.t
(** [input_metadata_with ~on_payload in_stream] *)

val input_package_without_payload : Bytream.In.t -> Metadata.t
(** [input_package_without_payload in_stream] *)

val input_package_with_string_payload :
  Bytream.In.t -> (metadata:Metadata.t * payload:string)
(** [input_package_with_string_payload in_stream] *)

val input_package_with_bigstring_payload :
  Bytream.In.t -> (metadata:Metadata.t * payload:Bstr.t)
(** [input_package_with_bigstring_payload in_stream] *)

(** {1 Decoder's error} *)

type error =
  | Invalid_rpm_code
  | Illegal_rpm_version
  | Illegal_rpm_Metadata_type
  | Invalid_header_record_code
  | Illegal_index_record_kind
  | Not_found_payload_size

exception Error of error
