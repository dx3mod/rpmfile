(** RPM package's metadata.

    {b Theoretical minimum}

    Each RPM package consists of four sections: [lead], [signature], [header],
    and [payload]. The first three are meta information about the package. It
    contains a description, a dependency list, and so on. The information in the
    [signature] and [header] is stored on a key-value basis (at header
    structures), where the key is called a [tag]. The value can be a [number], a
    [string] or an [array]. *)

(** RPM package's [Lead] section *)
module Lead : sig
  type t = {
    version : [ `V3 | `V4 ];
    kind : [ `Binary | `Source ];
    arch_num : int;
    name : string;
    os_num : int;
    signature_type : int;
  }
end

(** Key-value structure for storing tags. *)
module Header_structure : sig
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
(** RPM package's metadata type.

    {b Getting values from tags}

    For high-level access to the values of tags, you can use the {!View} module,
    which provides decoders to extract OCaml values from RPM package tags.
    Examples:

    {[
    Rpmfile.View.name metadata (* hello *)
    ]}
    {[
    let open Rpmfile.View in
    find_exn ~tag:1000 ~decode:string metadata (* hello *)
    ]} *)
