type lead = Lead.t

type header = (tag * value) list
and tag = int
and value = Header.index_value

type metadata = Types.metadata = {
  lead : lead;
  signature : header;
  header : header;
}

(** Angstrom parser. *)
module P : functor (_ : Selector.S) -> sig
  val metadata_parser : metadata Angstrom.t
end

(** Simple standard string or file reader with low performance. *)
module Reader : functor (_ : Selector.S) -> sig
  type result = (metadata, string) Stdlib.result

  exception Error of string

  val of_string : string -> result
  val of_string_exn : string -> metadata
  val of_file : string -> result
  val of_file_exn : string -> metadata
end

module Selector = Selector
module Tag = Tag
module Accessor = Accessor
module Types = Types

val name : Types.metadata -> string
val build_time : Types.metadata -> int
val build_host : Types.metadata -> string
val size : Types.metadata -> int
val description : Types.metadata -> string
val summary : Types.metadata -> string
val license : Types.metadata -> string
val os : Types.metadata -> string
val arch : Types.metadata -> string
val vendor : Types.metadata -> string
val packager : Types.metadata -> string
val group : Types.metadata -> string list
val url : Types.metadata -> string
