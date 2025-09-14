(** RPM package representation. *)

module Header_structure = struct
  type t = (tag * value) list
  and tag = int

  and value =
    | Null
    | Char of char
    | Int of int
    | Int32 of int32
    | Int64 of int64
    | String of string
    | Binary of Bigstringaf.t
    | StringArray of string list
    | Array of value list

  let pp fmt = function
    | Null -> Format.fprintf fmt "null"
    | Char c -> Format.fprintf fmt "'%c'" c
    | Int x -> Format.fprintf fmt "%d" x
    | Int32 x -> Format.fprintf fmt "%ldi32" x
    | Int64 x -> Format.fprintf fmt "%Ldi64" x
    | String x -> Format.fprintf fmt {|"%s"|} x
    | Binary x ->
        for i = 0 to Bigstringaf.length x - 1 do
          Bigstringaf.unsafe_get x i |> int_of_char |> Format.fprintf fmt "%02x"
        done
    | StringArray _ | Array _ -> Format.fprintf fmt "[array]"

  module Decoder = struct
    type 'a t = value -> 'a

    exception Decoding_failed of string

    let fail expected_type got_value =
      raise
      @@ Decoding_failed
           (Format.asprintf "expected %s but got %a" expected_type pp got_value)

    let int = function Int x -> x | v -> fail "Int" v
    and char = function Char x -> x | v -> fail "Char" v
    and int32 = function Int32 x -> x | v -> fail "Int32" v
    and int64 = function Int64 x -> x | v -> fail "Int64" v
    and string = function String x -> x | v -> fail "String" v
    and binary = function Binary x -> x | v -> fail "Binary" v
    and string_array = function StringArray x -> x | v -> fail "StringArray" v
    and array d = function Array xs -> List.map d xs | v -> fail "Array" v
    and nullable d = function Null -> None | v -> Some (d v)

    and any_int = function
      | Int x -> x
      | Int32 x -> Int32.to_int x
      | Int64 x -> Int64.to_int x
      | v -> fail "Int/Int32/Int64" v
  end

  let[@inline] get ~decode ~tag t = List.assoc tag t |> decode
end

type t = {
  lead : lead;
  signature : Header_structure.t;
  header : Header_structure.t;
  payload : string option;
}

and lead = {
  version : [ `V3 | `V4 ];
  kind : [ `Source | `Binary ];
  arch_num : int;
  name : string;
  os_num : int;
  signature_type : int;
}
