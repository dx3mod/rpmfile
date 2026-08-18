(** A pure OCaml library for parsing RPM files (supports V3 and partly V4
    package versions). *)

(** {1 Package} *)

(** The [Rpmfile] does not provide a single "package type", but instead it
    provides {!Metadata.t} and {!Payload.t}, which you can use to compose the
    package in the way you need. *)

module Metadata = Metadata
module Payload = Payload

(** {2 Content viewing} *)

module View = View

(** {1 Reader} *)

(** Powered by [Bytream] library. *)

module Reader = Reader
