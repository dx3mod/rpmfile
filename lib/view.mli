(** The module for viewing the contents of RPM package metadata ({!Metadata.t})
    and decoding {!Metadata.Header_structure} values into OCaml values allows
    you to find values by their tags, either by their number or by name.

    {b Example}

    {[
    let open Rpmfile.View in
    Printf.printf "%s.%s.rpm\n" (name metadata) (release metadata)
    (* hello.1.3.rpm *)
    ]} *)

(** {1 Getting values functions} *)

val name : Metadata.t -> string
(** [name metadata] returns RPM package's name. *)

val release : Metadata.t -> string
(** [release metadata] returns RPM package's release. *)

val epoch : Metadata.t -> string
(** [epoch metadata] returns RPM package's epoch. *)

val summery : Metadata.t -> string list
(** [summery metadata] returns RPM package's summery. *)

val description : Metadata.t -> string list
(** [description metadata] returns RPM package's description. *)

val sizes : Metadata.t -> int list
(** [sizes metadata] returns RPM package's file sizes. *)

val compressor : Metadata.t -> string
(** [sizes metadata] returns RPM package's compression used for payload. *)

(** {3 Finding} *)

val find_exn :
  ?name:string ->
  tag:int ->
  decode:(Metadata.Header_structure.value -> 'a option) ->
  Metadata.Header_structure.t ->
  'a
(** [find_exn ?name ~tag ~decode header_structure]

    Find the value of the [tag] in the [header_structure] and return the
    [decode]d value. See also {!Tags_table} module for tag numbers and the
    {!Decode} module for extract OCaml values from
    {!Metadata.Header_structure.value} representation.

    {b Example}

    {[
    Rpmfile.View.(find_exn ~tag:1000 ~decode:string) metadata (* hello *)
    ]}

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

module Decoder : sig
  type 'a t = Metadata.Header_structure.value -> 'a option

  val null : [> `Null ] t
  val char : char t
  val int : int t
  val int32 : int32 t
  val int64 : int64 t
  val string : string t
  val binary : string t
  val string_array : string list t
  val array : 'a t -> 'a list t
end
