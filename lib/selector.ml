module type S = sig
  val select_header_tag : int -> bool
  val select_signature_tag : int -> bool
end

module All : S = struct
  let select_header_tag _ = true
  let select_signature_tag _ = true
end

module Base = struct
  include All

  let select_header_tag tag =
    Tag.Header.(
      tag = name || tag = version || tag = release || tag = arch || tag = group
      || tag = size || tag = license || tag = source_rpm || tag = build_time
      || tag = build_host || tag = packager || tag = vendor || tag = url
      || tag = summary || tag = description || tag = distribution)
end
