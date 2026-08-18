module Tags_table = Tags_table

module Decoder = struct
  type 'a t = Metadata.Header_structure.value -> 'a option

  open Metadata.Header_structure

  let null = function Null -> Some `Null | _ -> None
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
    | Array list ->
        let rec aux = function
          | hd :: tl ->
              Option.bind (decode hd) @@ fun hd ->
              Option.map (List.cons hd) @@ aux tl
          | [] -> Some []
        in

        aux list
    | _ -> None
end

let find_exn ?name ~tag ~decode:value_decode entires =
  match Hashtbl.find entires tag |> value_decode with
  | None ->
      failwith
      @@ Printf.sprintf "fail to decode '%s' entry"
           (Option.value ~default:(string_of_int tag) name)
  | Some value -> value

open Decoder

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

and sizes m =
  find_exn ~name:"sizes" ~tag:1028 ~decode:(array int) m.Metadata.header

and compressor m =
  find_exn ~name:"compressor" ~tag:1125 ~decode:string m.Metadata.header
