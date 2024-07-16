type project_type = Source | Binary

let project_type_of_int = function
  | 0 -> Binary
  | 1 -> Source
  | _ -> failwith "bad project_type conversion"
