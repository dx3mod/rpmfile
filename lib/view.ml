module Tags_table = Tags_table

module Decoders = struct
  open Metadata.Header_structure

  let null = function Null -> Some None | _ -> None
  and char = function Char ch -> Some ch | _ -> None

  and int = function
    | Int x -> Some x
    | Int32 x -> Some (Int32.to_int x)
    | Int64 x -> Some (Int64.to_int x)
    | _ -> None

  and int32 = function Int32 x -> Some x | _ -> None
  and int64 = function Int64 x -> Some x | _ -> None
  and string = function String x -> Some x | _ -> None
  and binary = function Binary x -> Some x | _ -> None
  and string_array = function StringArray x -> Some x | _ -> None

  and array decode = function
    | Array xs -> Some List.(map decode xs)
    | _ -> None
end

let find_exn ?name ~tag ~decode:value_decode entires =
  match Hashtbl.find entires tag |> value_decode with
  | None ->
      failwith
      @@ Printf.sprintf "fail to decode '%s' entry"
           (Option.value ~default:(string_of_int tag) name)
  | Some value -> value

open Decoders

let name m =
  find_exn ~name:"name" ~tag:Tags_table.name ~decode:string m.Metadata.header

and release m =
  find_exn ~name:"release" ~tag:Tags_table.release ~decode:string
    m.Metadata.header

and epoch m =
  find_exn ~name:"epoch" ~tag:Tags_table.epoch ~decode:string m.Metadata.header

and summery m =
  find_exn ~name:"summery" ~tag:Tags_table.summary ~decode:string_array
    m.Metadata.header

and description m =
  find_exn ~name:"description" ~tag:Tags_table.description ~decode:string_array
    m.Metadata.header
