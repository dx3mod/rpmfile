(** A library for reading metadata from RPM packages using Eio abstractions. 

    {[
      let read_metadata path = 
          let module Rpm_reader = Rpmfile_eio.Reader.Make (Rpmfile.Selector.Base) in 
          let metadata = Path.with_open_in path (Rpm_reader.of_flow ~max_size:5_000) in
          (* ... *)
    ]}

  *)

module P = Parsers
(** [Eio.Buf_read]'s parsers.  *)

module Reader = Reader
(** Reader from [Eio.Flow.source] stream.  *)
