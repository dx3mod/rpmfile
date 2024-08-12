(** A library for reading metadata from RPM packages, providing an Angstrom parser. 

    {[
    module Rpm_reader = Rpmfile_unix.Reader.Make (Rpmfile.Selector.All)

    let _ = Rpm_reader.of_file "hello-2.12.1-1.7.x86_64.rpm"
    ]}

  *)

module Parsers = Parsers
(** Angstrom's parsers. *)

module Reader = Reader
(** Standard reader for sync reading from string or file.  *)
