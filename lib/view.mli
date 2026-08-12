(** The module for viewing the contents of the RPM package's metadata
    ({!Metadata.t} type) and decoding {!Metadata.Header_structure.value}s into
    OCaml values.

    This module allows you to find values by their tags, either by their number
    or by their name. *)

val name : Metadata.t -> string
val release : Metadata.t -> string
val epoch : Metadata.t -> string
val summery : Metadata.t -> string list
val description : Metadata.t -> string list

val find_exn :
  ?name:string ->
  tag:int ->
  decode:(Metadata.Header_structure.value -> 'a option) ->
  Metadata.Header_structure.t ->
  'a
(** [find_exn ?name ~tag ~decode header_structure]

    @param ?name
      Useful for understandable exception messages
      {[
      find_exn ~name:"woops" ~tag ~decode h
      (* Exception: Failure "fail to decode 'woops' entry" *)
      ]}

    @return
      a found (via [tag]) and decoded (via [decode] function) value from the
      [header_structure] entry.

    @raise Not_found if the [tag] not found.
    @raise Failure if decode was fail. *)

(** {1 Internals} *)

module Tags_table = Tags_table

module Decoders : sig
  val null : Metadata.Header_structure.value -> 'a option option
  val char : Metadata.Header_structure.value -> char option
  val int : Metadata.Header_structure.value -> int option
  val int32 : Metadata.Header_structure.value -> int32 option
  val int64 : Metadata.Header_structure.value -> int64 option
  val string : Metadata.Header_structure.value -> string option
  val binary : Metadata.Header_structure.value -> string option
  val string_array : Metadata.Header_structure.value -> string list option

  val array :
    (Metadata.Header_structure.value -> 'a) ->
    Metadata.Header_structure.value ->
    'a list option
end
