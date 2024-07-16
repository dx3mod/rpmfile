open Types

exception Error of string

let fail message = raise (Error message)
let sprintf = Printf.sprintf

let get_by_signature_tag f tag m =
  try List.assoc tag m.signature |> f
  with Not_found -> fail (sprintf "not found signature tag: %d" tag)

let get_by_header_tag f tag m =
  try List.assoc tag m.header |> f
  with Not_found -> fail (sprintf "not found header tag: %d" tag)

let string = function Header.String s -> s | _ -> fail "expected string"
let binary = function Header.Binary s -> s | _ -> fail "expected binary"
let any = Fun.id
let char = function Header.Char x -> x | _ -> fail "expected char"

let any_int = function
  | Header.Int x -> x
  | Header.Int32 x -> Int32.to_int x
  | Header.Int64 x -> Int64.to_int x
  | _ -> fail "expected any int"

let string_array = function
  | Header.StringArray s -> s
  | _ -> fail "expected string array"

let array f = function
  | Header.Array xs -> List.map f xs
  | _ -> fail "expected array"

let array' = array Fun.id
let ( << ) fa fb v = fa (fb v)
