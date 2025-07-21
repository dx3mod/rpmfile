module Internal = struct
  let get_header_tag pkg extract tag =
    List.assoc tag pkg.Package.header |> extract

  let get_header_tag_opt pkg extract tag =
    try get_header_tag pkg extract tag |> Option.some with Not_found -> None

  let get_signature_tag pkg extract tag =
    List.assoc tag pkg.Package.signature |> extract

  module Extract = struct
    open Package

    let null = function
      | Null -> `Null
      | _ -> raise (Invalid_argument "execpeted null")

    and string = function
      | String s -> s
      | _ -> raise (Invalid_argument "excepted string")

    and int32 = function
      | Int32 x -> x
      | _ -> raise (Invalid_argument "excepted int32")

    and int64 = function
      | Int64 x -> x
      | _ -> raise (Invalid_argument "excepted int64")

    and char = function
      | Char x -> x
      | _ -> raise (Invalid_argument "excepted char")

    and bin = function
      | Binary x -> x
      | _ -> raise (Invalid_argument "excepted binary")

    and array = function
      | Array x -> x
      | _ -> raise (Invalid_argument "excepted array")

    and string_array = function
      | StringArray x -> x
      | _ -> raise (Invalid_argument "excepted string array")

    and int = function
      | Int x -> x
      | Int32 x -> Int32.to_int x
      | Int64 x -> Int64.to_int x
      | _ -> raise (Invalid_argument "excepted native int")
  end
end

open Internal

module Tags = struct
  module Header = struct
    let name = 1000
    let version = 1001
    let release = 1002
    let epoch = 1003
    let summary = 1004
    let description = 1005
    let build_time = 1006
    let build_host = 1007
    let size = 1009
    let distribution = 1010
    let vendor = 1011
    let gif = 1012
    let xpm = 1013
    let license = 1014
    let packager = 1015
    let group = 1016
    let changelog = 1017
    let patch = 1019
    let url = 1020
    let os = 1021
    let arch = 1022
    let archive_size = 1046
    let payload_format = 1124
    let payload_compressor = 1125
    let payload_flags = 1126
    let source_rpm = 1044
    let cookie = 1094
    let dist_url = 1123
    let old_filenames = 1027
    let file_sizes = 1028
    let file_modes = 1030
    let file_devs = 1033
    let file_times = 1034
    let file_md5s = 1035
    let base_names = 1117
    let provide_name = 1047
    let require_name = 1049
    let platform = 1132
  end

  module Signature = struct
    let size = 1000
    let payload_size = 1007
    let md5 = 1004
    let sha1 = 269
  end
end

let name pkg = get_header_tag pkg Extract.string Tags.Header.name

let summary pkg =
  get_header_tag pkg Extract.string_array Tags.Header.summary |> List.hd

let description pkg =
  get_header_tag pkg Extract.string_array Tags.Header.description |> List.hd

let build_time pkg = get_header_tag pkg Extract.int Tags.Header.build_time
let build_host pkg = get_header_tag pkg Extract.string Tags.Header.build_host
