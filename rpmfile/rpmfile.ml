type lead = Lead.t
type header = Header.t
type metadata = { lead : lead; signature : header; header : header }

module Lead = Lead
module Header = Header
module Selector = Selector
module D = Decode

exception Not_found of string

let get_value tag header = List.assoc tag header

let get' ~msg decoder tag header =
  try get_value tag header |> decoder
  with Stdlib.Not_found ->
    raise
    @@ Not_found (match msg with Some s -> s | None -> string_of_int tag)

let get_opt' decoder tag header =
  try Some (get_value tag header |> decoder) with Stdlib.Not_found -> None

let get ?msg (decoder : 'a D.decoder) tag metadata =
  get' ~msg decoder tag metadata.header

let get_opt (decoder : 'a D.decoder) tag metadata =
  get_opt' decoder tag metadata.header

let get_from_signature ?msg (decoder : 'a D.decoder) tag metadata =
  get' ~msg decoder tag metadata.signature

let get_opt_from_signature (decoder : 'a D.decoder) tag metadata =
  get_opt' decoder tag metadata.signature

let name = get ~msg:"name" D.string Tag.Header.name

let rec summary' = get ~msg:"summery" D.string_array Tag.Header.summary
and summary m = summary' m |> List.hd

let rec description' =
  get ~msg:"description" D.string_array Tag.Header.description

and description m = description' m |> List.hd

let build_time = get ~msg:"build_time" D.native_int Tag.Header.build_time
and build_host = get ~msg:"build_host" D.string Tag.Header.build_host

let size = get ~msg:"size" D.native_int Tag.Header.size
let os = get ~msg:"os" D.string Tag.Header.os
let license = get ~msg:"license" D.string Tag.Header.license
let vendor = get ~msg:"vendor" D.string Tag.Header.vendor
let version = get ~msg:"version" D.string Tag.Header.version
let release = get ~msg:"release" D.string Tag.Header.release
let packager = get ~msg:"packager" D.string Tag.Header.packager
let distribution = get ~msg:"distribution" D.string Tag.Header.distribution
let group = get ~msg:"group" D.string_array Tag.Header.group
let url = get ~msg:"url" D.string Tag.Header.url
let dist_url = get ~msg:"dist_url" D.string Tag.Header.dist_url
let arch = get ~msg:"arch" D.string Tag.Header.arch
let archive_size = get_opt D.native_int Tag.Header.archive_size
let md5 = get_opt_from_signature D.binary Tag.Signature.md5
let sha1 = get_from_signature ~msg:"sha1" D.binary Tag.Signature.sha1

let payload_size =
  get_from_signature ~msg:"payload_size" D.native_int Tag.Signature.payload_size

let payload_format =
  get ~msg:"payload_format" D.string Tag.Header.payload_format

let payload_compressor =
  get ~msg:"payload_compressor" D.string Tag.Header.payload_compressor

let payload_flags = get ~msg:"payload_flags" D.string Tag.Header.payload_flags
let source_rpm = get ~msg:"source_rpm" D.string Tag.Header.source_rpm
let filenames = get ~msg:"base_names" D.string_array Tag.Header.base_names
let platform = get ~msg:"platform" D.string Tag.Header.platform

let provide_names =
  get ~msg:"provide_name" D.string_array Tag.Header.provide_name

let require_names =
  get ~msg:"require_name" D.string_array Tag.Header.require_name
