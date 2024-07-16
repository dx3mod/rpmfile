(** A RPM(v3) package metadata parser powered by Angstrom. *)

type metadata = Types.metadata = {
  lead : Lead.t;
  signature : header;
  header : header;
}
(** RPM file metadata.  *)

and header = (Tag.t * Header.index_value) list

(** Angstrom parsers.  *)
module P : functor (_ : Selector.S) -> sig
  val metadata_parser : metadata Angstrom.t
end

(** Simple standard string or file reader with low performance. *)
module Reader : functor (_ : Selector.S) -> sig
  type result = (metadata, string) Stdlib.result

  exception Error of string
  (** Parsing error.  *)

  val of_string : string -> result

  val of_string_exn : string -> metadata
  (** @raise Error *)

  val of_file : string -> result

  val of_file_exn : string -> metadata
  (** @raise Error *)
end

module Selector = Selector
(** Predicate for parsing only necessary tags. *)

module Types = Types

module Tag = Tag
(** Tag number constants for signature and header sections. *)

module D = Decode
(** Set of combinators for decoding value of type [value].  *)

module Header = Header
module Lead = Lead

exception Not_found of string
(** Not found tag.  *)

exception Decode_error of string
(** Decode [value] type value error.  *)

val get : ?msg:string -> 'a D.decoder -> Tag.t -> metadata -> 'a
(** Get a index value from header section by tag and decode it.
    @raise Not_found 
    @raise Decode_error *)

val get_from_signature : ?msg:string -> 'a D.decoder -> Tag.t -> metadata -> 'a
(** Get a index value from signature section by tag and decode it.
    @raise Not_found 
    @raise Decode_error *)

val name : metadata -> string
val summary' : metadata -> string list
val summary : metadata -> string
val description' : metadata -> string list
val description : metadata -> string
val build_time : metadata -> int32
val build_host : metadata -> string
val size : metadata -> int32
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
