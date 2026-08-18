(** The module implements CPIO archive reader.

    {b Example}

    {[
    let file_entries = Rpmfile_cpio.Reader.input_entries in_stream in
    List.iter print_endline file_entries
    ]} *)

(** {1 Modules} *)

module File_entry = File_entry
module Header = Header
module Reader = Reader
