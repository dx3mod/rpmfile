type t = int

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
