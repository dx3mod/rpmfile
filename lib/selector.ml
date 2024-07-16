module type S = sig
  val select_header_tag : int -> bool
  val select_signature_tag : int -> bool
end

module All : S = struct
  let select_header_tag _ = true
  let select_signature_tag _ = true
end
