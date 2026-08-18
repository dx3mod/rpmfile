(** The module provides functions to read CPIO archives from incoming byte
    streams. *)

module In = Bytream.In
(** The short alias to incoming byte streams. *)

exception Not_supported_format

(** {1 Inputting file entry from archives} *)

val input_entry_with :
  input_payload:(In.t -> int -> File_entry.contents) -> In.t -> File_entry.t

(** [input_entry_with ~input_payload in_stream]

    Input a file entry from an incoming byte stream using the input payload via
    the [input_payload] function.

    {b Example}

    {[
    let input_payload in_stream payload_size = (* processing *) in
    Rpmfile_cpio.Reader.input_entry_with ~input_payload in_stream
    ]}

    @raise Not_supported_format if magic code not matched *)

val input_entry_without_payload : In.t -> File_entry.t_without_payload
(** [input_entry_without_payload in_stream]

    Similar to the {!input_entry_with} function, but it skips file entries
    payload. *)

val input_entry : In.t -> File_entry.t_with_string_payload
(** [input_entry in_stream]

    Similar to the {!input_entry_with} function, it inputs file entries as
    string. *)

(** {1 Inputting all file entries from archives} *)

val input_entries_with :
  input_payload:(In.t -> int -> File_entry.contents) ->
  In.t ->
  int ->
  File_entry.t list
(** [input_entries_wit ~input_payload in_stream n]

    Input the [n] number of file entries from the incoming byte stream by using
    the input payload via the [input_payload] function.

    {b See also} the {!input_entry_with} function for details. *)

val input_entries_seq_with :
  input_payload:(In.t -> int -> File_entry.contents) ->
  In.t ->
  int ->
  File_entry.t Seq.t
(** [input_entries_seq_with ~input_payload in_stream n]

    Similar to the {!input_entries_with} function, but returns lazy sequence. *)

val input_entries_without_payloads :
  In.t -> int -> File_entry.t_without_payload list
(** [input_entries_without_payloads in_stream n]

    Similar to the {!input_entries_with} function, but it skips file entries
    payloads. *)

val input_entries : In.t -> int -> File_entry.t_with_string_payload list
(** [input_entries in_stream n]

    Similar to the {!input_entry_with} function, it inputs file entries as
    strings. *)

val input_entries_seq : In.t -> int -> File_entry.t_with_string_payload Seq.t
(** [input_entries in_stream n]

    Similar to the {!input_entries} function, but returns lazy sequence. *)
