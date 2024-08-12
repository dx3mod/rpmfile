module Rpm_reader = Rpmfile_eio.Reader.Make (Rpmfile.Selector.All)

let metadata =
  Eio_main.run (fun env ->
      let path =
        Eio.Path.(env#fs / "../../test_misc/hello-2.12.1-1.7.x86_64.rpm")
      in
      Eio.Path.with_open_in path (Rpm_reader.of_flow ~max_size:10_000))

let () =
  let open Alcotest in
  let open Testlib in
  run "Rpmfile_eio (Selector.All)"
    [
      ( "hello-2.12.1-1.7.x86_64.rpm",
        [
          test_case "name" `Quick (test_name metadata);
          test_case "version" `Quick (test_version metadata);
          test_case "filenames" `Quick (test_array_string metadata);
        ] );
    ]
