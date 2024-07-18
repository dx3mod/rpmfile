open Meta

type t = {
  version : int * int;
  kind : project_type;
  arch_num : int;
  name : string;
  os_num : int;
  signature_type : int;
}

let parser =
  let open Angstrom in
  let* _ =
    string "\xED\xAB\xEE\xDB" <|> fail "invalid lead section magic number"
  in
  let* version =
    both (int8 3 <|> int8 4) (int8 0) <|> fail "invalid package version"
  in
  let* kind =
    int8 0 *> int8 0
    <|> int8 1 >>| project_type_of_int
    <|> fail "invalid project type"
  in
  let* arch_num = BE.any_int16 in
  let* name =
    let* name = take_till (fun c -> c = '\x00') in
    let+ _ = advance (66 - String.length name) in
    name
  in
  let* os_num = BE.any_int16 in
  let* signature_type = BE.any_int16 in

  let* _ = advance 16 in

  return { version; kind; arch_num; name; os_num; signature_type }
