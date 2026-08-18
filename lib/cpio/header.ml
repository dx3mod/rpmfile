(** The CPIO Header module. *)

type t = {
  inode_number : int;
  permission_bits : int;
  user_id : int;
  group_id : int;
  nlink : int;
  modification_time : int;
  file_size : int;
  major_device_number : int;
  minor_device_number : int;
  major_raw_device_number : int;
  minor_raw_device_number : int;
  name_size : int;
  checksum : int;
}
