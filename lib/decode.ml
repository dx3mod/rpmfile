type 'a decoder = Header.index_value -> 'a

exception Error of string

let fail message = raise (Error message)
let string = function Header.String s -> s | _ -> fail "expected string"
let binary = function Header.Binary s -> s | _ -> fail "expected binary"
let any = Fun.id
let char = function Header.Char x -> x | _ -> fail "expected char"

let int = function
  | Header.Int x -> x
  | Header.Int32 x -> Int32.to_int x
  | _ -> fail "expected int"

let int32 = function Header.Int32 x -> x | _ -> fail "expected int32"
let int64 = function Header.Int64 x -> x | _ -> fail "expected int64"

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
let opt f v = try Some (f v) with Error _ -> None
