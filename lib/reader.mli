module Selector : sig
  module type S = sig
    val select_header_entries : Package.header_tag -> bool
    val select_signature_entries : Package.header_tag -> bool
  end

  module Default : S
end

module Make : (_ : Selector.S) -> sig
  val package_parser : Package.t Angstrom.t
  val of_string : string -> (Package.t, string) result
  val of_bigstring : Bigstringaf.t -> (Package.t, string) result
  val of_channel : in_channel -> (Package.t, string) result
end

(** Default reader that read all tags without body. *)
module Default : sig
  val package_parser : Package.t Angstrom.t
  val of_string : string -> (Package.t, string) result
  val of_bigstring : Bigstringaf.t -> (Package.t, string) result
  val of_channel : in_channel -> (Package.t, string) result
end

val is_package : string -> bool
