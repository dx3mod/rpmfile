(** A pure OCaml library for processing (reading and writing) RPM packages,
    supporting versions 3.0 and partly version 4.0. *)

(** {1 Package} *)

(** The [Rpmfile] does not provide a single "package type", but instead it
    provides {!Metadata.t} and {!Payload.t}, which you can use to compose the
    package in the way you need. *)

module Metadata = Metadata
module Payload = Payload

(** {2 Content viewing} *)

module View = View

(** {1 Reader & Writer} *)

module Reader = Reader
module Writer = Writer
