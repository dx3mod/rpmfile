type t = {
  lead : lead;
  signature : header_structure;
  header : header_structure;
}

and lead = {
  version : [ `V3 | `V4 ];
  kind : [ `Source | `Binary ];
  arch_num : int;
  name : string;
  os_num : int;
  signature_type : int;
}

and header_structure = (int * header_structure_value) list

and header_structure_value =
  | Null
  | Char of char
  | Int of int
  | Int32 of int32
  | Int64 of int64
  | String of string
  | Binary of string
  | StringArray of string list
  | Array of header_structure_value list
