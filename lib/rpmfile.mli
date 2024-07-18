(** RPM package metadata reader. *)

type lead = Lead.t
type header = (int * Header.index_value) list

type metadata = Types.metadata = {
  lead : lead;
  signature : header;
  header : header;
}

(** Angstrom parsers. *)
module P : functor (_ : Selector.S) -> sig
  val metadata_parser : metadata Angstrom.t
end

(** Standard reader with poor performance for reading from string or file.  *)
module Reader : functor (_ : Selector.S) -> sig
  type result = (metadata, string) Stdlib.result
  (** Result of metadata value or parsing error. *)

  exception Error of string
  (** Parsing error. *)

  val of_string : string -> result
  val of_string_exn : string -> metadata
  val of_file : string -> result
  val of_file_exn : string -> metadata
end

module Selector = Selector
(** Predicate for parsing only necessary tags. *)

module Types = Types
module Tag = Tag

module D = Decode
(** [value] type's decoders. *)

module Header = Header
(** Representation of Header and Signature sections. *)

module Lead = Lead
(** Representation of Lead section. *)

exception Not_found of string
exception Decode_error of string

val get_value : 'a -> ('a * 'b) list -> 'b
(** Help function for getting value from assoc list. *)

val get : ?msg:string -> 'a D.decoder -> int -> metadata -> 'a
(** [get ?msg decoder tag metadata] to find value by tag and decoder it.
    @raise Not_found
    @raise Decode_error If value doesn't have expected type.
 *)

val get_opt : 'a D.decoder -> int -> metadata -> 'a option
(** Similar to [get] function, but returns an optional type instead of exceptions if the tag is not found.
    @raise Decode_error *)

val get_from_signature : ?msg:string -> 'a D.decoder -> int -> metadata -> 'a
(** Similar to [get] function, but for Signature section. *)

val get_opt_from_signature : 'a D.decoder -> int -> metadata -> 'a option
val name : metadata -> string
val summary' : metadata -> string list
val summary : metadata -> string
val description' : metadata -> string list
val description : metadata -> string

val build_time : metadata -> int32
(** @return Unix-time. *)

val build_host : metadata -> string

val size : metadata -> int32
(** Sum of the sizes of the regular files in the archive. *)

val os : metadata -> string
val license : metadata -> string
val vendor : metadata -> string
val version : metadata -> string
val packager : metadata -> string
val group : metadata -> string list
val url : metadata -> string
val arch : metadata -> string
val archive_size : metadata -> int32
val md5 : metadata -> Bigstringaf.t option
val sha1 : metadata -> Bigstringaf.t
val payload_size : metadata -> int32
