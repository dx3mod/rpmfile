module Rpm_pkg_reader = Rpmfile_unix.Reader.Make (Rpmfile.Selector.All)

let show_pkg_info path =
  let open Printf in
  let metadata =
    match Rpm_pkg_reader.of_file path with
    | Ok metadata -> metadata
    | Error msg ->
        prerr_endline msg;
        exit 1
  in

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

  List.iter show_pkg_info !package_filenames
