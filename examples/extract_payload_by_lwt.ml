let default_tags_selector =
  Rpmfile.Reader.
    {
      predicate_signature_tag = Fun.const true;
      predicate_header_tag = Fun.const true;
    }

let pkg_parser =
  Rpmfile.Reader.make_package_parser ~capture_payload:false
    ~tags_selector:default_tags_selector

let () =
  let open Lwt.Syntax in
  Lwt_main.run
  @@
  let* ic = Lwt_io.open_file ~mode:Input Sys.argv.(1) in
  let* _pkg =
    let* b, r = Angstrom_lwt_unix.parse pkg_parser ic in
    let+ _ = Lwt_io.set_position ic (Int64.of_int b.off) in
    Result.get_ok r
  in
  let* payload = Lwt_io.read ic in

  Lwt_io.with_file ~mode:Output Sys.argv.(2) (fun oc -> Lwt_io.write oc payload)
