(** Predicate for parsing only necessary tags. *)

module type S = sig
  val select_header_tag : Tag.t -> bool
  val select_signature_tag : Tag.t -> bool
end

(** For reading all tags.  *)
module All : S = struct
  let select_header_tag _ = true
  let select_signature_tag _ = true
end

(** For reading base tags. 
    - base, version, release, arch, group, size, license,
    source_rpm, build_time, build_host, packager, vendor, url, summary, description, distribution. *)
module Base : S = struct
  include All

  let select_header_tag tag =
    Tag.Header.(
      tag = name || tag = version || tag = release || tag = arch || tag = group
      || tag = size || tag = license || tag = source_rpm || tag = build_time
      || tag = build_host || tag = packager || tag = vendor || tag = url
      || tag = summary || tag = description || tag = distribution)
end
