type index = { number_of_index : int; section_size : int }

module Entry = struct
  type record = { tag : int; kind : int; offset : int; count : int }

  and value =
    | Null
    | Char of char
    | Int of int
    | Int32 of int32
    | Int64 of int64
    | String of string
    | Binary of bytes
    | StringArray of string list
    | Array of value list
end

type t = (Tag.t * Entry.value) list
