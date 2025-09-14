(** The module for reading RPM packages from different sources. *)

type tags_selector = {
  predicate_signature_tag : int -> bool;
  predicate_header_tag : int -> bool;
}

val make_package_parser :
  tags_selector:tags_selector -> capture_payload:bool -> Package.t Angstrom.t

val of_string :
  ?tags_selector:tags_selector ->
  ?capture_payload:bool ->
  string ->
  (Package.t, string) result

val of_bigstring :
  ?tags_selector:tags_selector ->
  ?capture_payload:bool ->
  Bigstringaf.t ->
  (Package.t, string) result

val of_channel :
  ?tags_selector:tags_selector ->
  ?capture_payload:bool ->
  in_channel ->
  (Package.t, string) result
