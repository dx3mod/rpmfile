type t = {
  version : int * int;
  kind : project_type;
  arch_num : int;
  name : string;
  os_num : int;
  signature_type : int;
}

and project_type = Source | Binary
