let show_pkg_info path =
  let open Printf in
  let module Rpm_reader = Rpmfile.Reader (Rpmfile.Selector.All) in
  let metadata = Rpm_reader.of_file_exn path in

  let get_build_date () =
    let date = Unix.localtime (Int32.to_float (Rpmfile.build_time metadata)) in
    let day = date.Unix.tm_mday in
    let month = date.Unix.tm_mon + 1 in
    let year = date.Unix.tm_year + 1900 in
    sprintf "%04d-%02d-%02d" year month day
  in

  printf "Name        : %s\n" (Rpmfile.name metadata);
  printf "Version     : %s\n" (Rpmfile.version metadata);
  printf "Architecture: %s\n" (Rpmfile.arch metadata);
  printf "Group       : %s\n" (Rpmfile.group metadata |> String.concat " ");
  printf "Size        : %ld\n" (Rpmfile.size metadata);
  printf "License     : %s\n" (Rpmfile.license metadata);
  printf "Build Date  : %s\n" (get_build_date ());
  printf "Build Host  : %s\n" (Rpmfile.build_host metadata);
  printf "Packager    : %s\n" (Rpmfile.packager metadata);
  printf "Vendor      : %s\n" (Rpmfile.vendor metadata);
  printf "URL         : %s\n" (Rpmfile.url metadata);
  printf "Summary     : %s\n" (Rpmfile.summary metadata);
  printf "Description :\n%s\n" (Rpmfile.description metadata);

  ()

let () =
  let package_filename = ref "" in
  Arg.parse []
    (fun filename -> package_filename := filename)
    "Similar to 'rpm -qi' command.";

  if !package_filename <> "" then show_pkg_info !package_filename
