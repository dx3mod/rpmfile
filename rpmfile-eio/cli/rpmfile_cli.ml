open Eio

let show_pkg_info path =
  let open Printf in
  let module Rpm_reader = Rpmfile_eio.Reader.Make (Rpmfile.Selector.All) in
  let metadata = Path.with_open_in path (Rpm_reader.of_flow ~max_size:5_000) in

  let get_build_date () =
    let date = Unix.localtime (float_of_int (Rpmfile.build_time metadata)) in
    let day = date.Unix.tm_mday in
    let month = date.Unix.tm_mon + 1 in
    let year = date.Unix.tm_year + 1900 in
    sprintf "%04d-%02d-%02d" year month day
  in

  printf "Name        : %s\n" (Rpmfile.name metadata);
  printf "Version     : %s\n" (Rpmfile.version metadata);
  printf "Release     : %s\n" (Rpmfile.release metadata);
  printf "Architecture: %s\n" (Rpmfile.arch metadata);
  printf "Group       : %s\n" (Rpmfile.group metadata |> List.hd);
  printf "Size        : %d\n" (Rpmfile.size metadata);
  printf "License     : %s\n" (Rpmfile.license metadata);
  (* TODO: signature *)
  printf "Source RPM  : %s\n" (Rpmfile.source_rpm metadata);
  printf "Build Date  : %s\n" (get_build_date ());
  printf "Build Host  : %s\n" (Rpmfile.build_host metadata);
  printf "Packager    : %s\n" (Rpmfile.packager metadata);
  printf "Vendor      : %s\n" (Rpmfile.vendor metadata);
  printf "URL         : %s\n" (Rpmfile.url metadata);
  printf "Summary     : %s\n" (Rpmfile.summary metadata);
  printf "Description :\n%s\n" (Rpmfile.description metadata);
  printf "Distribution: %s\n" (Rpmfile.distribution metadata);

  ()

let () =
  let package_filenames = ref [] in
  Arg.parse []
    (fun filename -> package_filenames := filename :: !package_filenames)
    "Similar to 'rpm -qi' command.\nUsage: rpmfile [FILENAMES]";

  Eio_main.run @@ fun env ->
  List.iter
    (fun filename -> show_pkg_info Path.(env#fs / filename))
    !package_filenames
