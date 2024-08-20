(** This module has a type definition and functions that make it easy to access fields.
    If you want to read a package, you can use one of the backends ([rpmfile_unix] or [rpmfile_eio]).   *)

(*******************************************************************)
(** {1 Types}  *)

type lead = Lead.t
(** Package Lead section. *)

type header = Header.t
(** Package Signature/Header section. *)

type metadata = { lead : lead; signature : header; header : header }

(** {3 Modules}  *)

module Lead = Lead
module Header = Header
module Selector = Selector
module D = Decode

(*******************************************************************)
(** {1 Access functions}  *)

exception Not_found of string
(** Exception for not found fields. *)

(** {2 High-level}  *)

(** If the field is not found, an [Not_found] exception is returned.  *)

(** {3 Header fields}  *)

val name : metadata -> string
val summary' : metadata -> string list
val summary : metadata -> string
val description' : metadata -> string list
val description : metadata -> string
val build_time : metadata -> int
val build_host : metadata -> string
val size : metadata -> int
val os : metadata -> string
val license : metadata -> string
val vendor : metadata -> string
val version : metadata -> string
val release : metadata -> string
val packager : metadata -> string
val distribution : metadata -> string
val group : metadata -> string list
val url : metadata -> string
val dist_url : metadata -> string
val arch : metadata -> string
val archive_size : metadata -> int option
val payload_format : metadata -> string
val payload_compressor : metadata -> string
val payload_flags : metadata -> string
val source_rpm : metadata -> string
val filenames : metadata -> string list
val platform : metadata -> string
val provide_names : metadata -> string list
val require_names : metadata -> string list

(** {3 Signature fields}  *)

val md5 : metadata -> bytes
val sha1 : metadata -> string
val payload_size : metadata -> int

(** {2 Low-level}  *)

(** @raise Not_found if the tag is not found.
    @raise D.Error if decoding of the value failed.  *)

val get_value : 'a -> ('a * 'b) list -> 'b
val get' : msg:string option -> ('a -> 'b) -> int -> (int * 'a) list -> 'b
val get_opt' : ('a -> 'b) -> 'c -> ('c * 'a) list -> 'b option
val get : ?msg:string -> 'a D.decoder -> int -> metadata -> 'a
val get_opt : 'a D.decoder -> int -> metadata -> 'a option
val get_from_signature : ?msg:string -> 'a D.decoder -> int -> metadata -> 'a
val get_opt_from_signature : 'a D.decoder -> int -> metadata -> 'a option
