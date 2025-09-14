type tags_selector = {
  predicate_signature_tag : Package.Header_structure.tag -> bool;
  predicate_header_tag : Package.Header_structure.tag -> bool;
}

let default_tags_selector =
  {
    predicate_signature_tag = Fun.const true;
    predicate_header_tag = Fun.const true;
  }

let[@inline] make_package_parser ~tags_selector ~capture_payload =
  Parsers.package ~predicate_signature_tag:tags_selector.predicate_signature_tag
    ~predicate_header_tag:tags_selector.predicate_header_tag ~capture_payload

let of_string ?(tags_selector = default_tags_selector)
    ?(capture_payload = false) s =
  Angstrom.(parse_string ~consume:Prefix)
    (make_package_parser ~tags_selector ~capture_payload)
    s

let of_bigstring ?(tags_selector = default_tags_selector)
    ?(capture_payload = false) s =
  Angstrom.(parse_bigstring ~consume:Prefix)
    (make_package_parser ~tags_selector ~capture_payload)
    s

let of_channel ?(tags_selector = default_tags_selector)
    ?(capture_payload = false) ic =
  In_channel.input_all ic |> of_string ~tags_selector ~capture_payload
