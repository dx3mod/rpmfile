(** The module provides functions to read RPM packages from incoming byte
    streams. *)

module In = Bytream.In
(** Short alias to incoming byte stream. *)

(** {1 Input RPM package functions} *)

(** {2 From channels} *)

val from_channel_without_payload : in_channel -> Metadata.t
(** [from_channel_without_payload ic]

    Similar to {!input_package_without_payload}, but for channels. *)

val from_channel_with_payload : in_channel -> Metadata.t * Payload.t
(** [from_channel_with_payload ic]

    Similar to {!input_metadata_with_bigstring_payload}, but for channels. *)

(** {2 From incoming byte streams} *)

val input_metadata_only : In.t -> Metadata.t
(** [input_metadata_only in_stream]

    Input {b only} package's metadata from incoming byte stream, without
    skipping payload. The remaining payload is available for the user to analyze
    on their own.

    {b See also}

    - If you want to input full package bytes, but ignore the payload section,
      you should use {!input_package_without_payload}.

    - If you want to get the package's payload and its metadata, you should see
      it with {!input_metadata_with} and [input_package_with...payload]. It's
      very {b important}, because the value of the [RPMTAG_PAYLOADSIZE] tag is
      not just the payload size, but also includes the size of the package
      header plus the payload.

    @raise Error if parsing fails *)

val input_package_without_payload : In.t -> Metadata.t
(** [input_package_without_payload in_stream]

    Similar to the {!input_metadata_only} function, but skip the payload section
    from the stream's source.

    @raise Error if parsing fails *)

(** {3 With payload} *)

val input_metadata_with : In.t -> (Metadata.t -> int -> 'a) -> 'a
(** [input_metadata_with in_stream f]

    Input the package's metadata and call the [f] function to handle the payload
    section of the package.

    {b Example}
    {[
    Rpmfile.Reader.input_metadata_with in_stream
    @@ fun metadata payload_size ->
    (* ... *)
    ]}

    @raise Error if parsing fails *)

val input_metadata_with_string_payload : In.t -> Metadata.t * string
(** [input_package_with_string_payload in_stream] *)

val input_metadata_with_bigstring_payload : In.t -> Metadata.t * Bstr.t
(** [input_package_with_bigstring_payload in_stream] *)

(** {1 Decoder's error} *)

type error =
  | Invalid_rpm_code
  | Illegal_rpm_version
  | Illegal_rpm_metadata_type
  | Invalid_header_record_code
  | Illegal_index_record_kind
  | Not_found_payload_size

exception Error of error
