(** Functions for getting tag values from package *)

(** Internal. *)
module Internal = struct
  let[@inline] get_from_signature decode tag pkg =
    Package.Header_structure.get ~decode ~tag pkg.Package.signature

  let[@inline] get_from_signature_opt decode tag pkg =
    try get_from_signature decode tag pkg |> Option.some
    with Not_found -> None

  let[@inline] get_from_header decode tag pkg =
    Package.Header_structure.get ~decode ~tag pkg.Package.header

  let[@inline] get_from_header_opt decode tag pkg =
    try get_from_header decode tag pkg |> Option.some with Not_found -> None
end

open Internal
open Package.Header_structure.Decoder

let name = get_from_header string 1000
and version = get_from_header string 1001
and release = get_from_header string 1002
and epoch = get_from_header_opt string 1003
and summary = get_from_header string_array 1004
and description = get_from_header string_array 1005
and build_time = get_from_header any_int 1006
and build_host = get_from_header string 1007
and size = get_from_header any_int 1009
and distribution = get_from_header string 1010
and vendor = get_from_header string 1011
and license = get_from_header string 1014
and packager = get_from_header string 1015
and group = get_from_header string_array 1016
and patch = get_from_header string_array 1019
and url = get_from_header string 1020
and os = get_from_header string 1021
and arch = get_from_header string 1022
and archive_size = get_from_header string 1046
and payload_format = get_from_header string 1124
and payload_compressor = get_from_header string 1125
and payload_flags = get_from_header string 1126
and source_rpm = get_from_header string 1126
and cookie = get_from_header string 1044
and dist_url = get_from_header_opt string 1123
and file_sizes = get_from_header (array int) 1028
and file_modes = get_from_header (array int) 1030
and file_devs = get_from_header (array int) 1033
and file_times = get_from_header (array int) 1034
and file_md5s = get_from_header string_array 1035
and provide_name = get_from_header string_array 1047
and require_name = get_from_header string_array 1049
and platform = get_from_header string 1132

let changelog pkg =
  ( get_from_header (array int32) 1080 pkg,
    get_from_header string_array 1081 pkg,
    get_from_header string_array 1082 pkg )
