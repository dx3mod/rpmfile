module Parsers = struct
  open Angstrom

  let lead_version_of_int = function
    | 0x0300 -> `V3
    | 0x0400 -> `V4
    | _ -> raise (Invalid_argument "lead version")

  let lead_kind_of_int = function
    | 0 -> `Binary
    | 1 -> `Source
    | _ -> raise (Invalid_argument "lead kind (binary or source)")

  let lead =
    let* _ = string "\xED\xAB\xEE\xDB" <|> fail "invalid LEAD section" in
    let* version = BE.any_int16 >>| lead_version_of_int in
    let* kind = BE.any_int16 >>| lead_kind_of_int in
    let* arch_num = BE.any_int16 in
    let* name =
      let* name = take_till (fun c -> c = '\x00') in
      (* NOTE: breake if name's lengtht > 66 *)
      let+ _ = advance (66 - String.length name) in
      name
    in
    let* os_num = BE.any_int16 in
    let* signature_type = BE.any_int16 in

    let* _ = advance 16 in

    return Rpm_package.{ version; kind; arch_num; name; os_num; signature_type }

  type header_index = { number_of_index : int; section_size : int }
  and header_entry = { tag : int; kind : int; offset : int; count : int }

  let header_index =
    let* _ =
      string "\x8E\xaD\xE8\x01" <|> fail "invalid header section magic number"
    in
    let* _ = advance 4 in
    let* number_of_index = BE.any_int32 >>| Int32.to_int in
    let* section_size = BE.any_int32 >>| Int32.to_int in

    return { number_of_index; section_size }
end
