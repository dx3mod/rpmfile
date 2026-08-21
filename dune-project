(lang dune 3.6)

(name rpmfile)

(version 1.0.0)

(generate_opam_files true)

(source
 (github dx3mod/rpmfile))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name rpmfile)
 (synopsis "A pure OCaml library for parsing RPM files")
 (description
  "A library for processing (reading and writing) RPM files, supporting version 3.0 and partly 4.0.")
 (depends
  (ocaml
   (>= 4.14))
  (bytream
   (>= 0.2))
  dune)
 (tags
  (rpm rpmfile)))
