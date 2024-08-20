(** Collection of decoders for convert from [Header.Entry.value] to user type. *)

open Header.Entry

type 'a decoder = value -> 'a

exception Error of string

let fail message = raise (Error message)
let string = function String s -> s | _ -> fail "expected string"
let binary = function Binary s -> s | _ -> fail "expected binary"
let any = Fun.id
let char = function Char x -> x | _ -> fail "expected char"
let int = function Int x -> x | _ -> fail "expected int"
let int32 = function Int32 x -> x | _ -> fail "expected int32"
let int64 = function Int64 x -> x | _ -> fail "expected int64"

let native_int = function
  | Int x -> x
  | Int32 x -> Int32.to_int x
  | Int64 x -> Int64.to_int x
  | _ -> fail "expected any int"

let string_array = function
  | StringArray s -> s
  | _ -> fail "expected string array"

let array f = function Array xs -> List.map f xs | _ -> fail "expected array"
let array' = array Fun.id
let ( << ) fa fb v = fa (fb v)
