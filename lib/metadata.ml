module Lead = struct
  type t = {
    version : [ `V3 | `V4 ];
    kind : [ `Source | `Binary ];
    arch_num : int;
    name : string;
    os_num : int;
    signature_type : int;
  }
end

module Header_structure = struct
  type t = (int, value) Hashtbl.t

  and value =
    | Null
    | Char of char
    | Int of int
    | Int32 of int32
    | Int64 of int64
    | String of string
    | Binary of string
    | StringArray of string list
    | Array of value list
end

type t = {
  lead : Lead.t;
  signature : Header_structure.t;
  header : Header_structure.t;
}
