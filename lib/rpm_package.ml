type t = { lead : lead; signature : header; header : header }

and lead = {
  version : [ `V3 | `V4 ];
  kind : [ `Source | `Binary ];
  arch_num : int;
  name : string;
  os_num : int;
  signature_type : int;
}

and header = (header_tag * header_entry_value) list
and header_tag = int

and header_entry_value =
  | Null
  | Char of char
  | Int of int
  | Int32 of int32
  | Int64 of int64
  | String of string
  | Binary of bytes
  | StringArray of string list
  | Array of header_entry_value list

let lead_version_of_int = function
  | 0x0300 -> `V3
  | 0x0400 -> `V4
  | _ -> raise (Invalid_argument "lead version")

let lead_kind_of_int = function
  | 0 -> `Binary
  | 1 -> `Source
  | _ -> raise (Invalid_argument "lead kind (binary or source)")
