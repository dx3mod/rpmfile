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
 (synopsis "RPM package reader")
 (description "A library for processing RPM packages, supporting version 3.0 and partly 4.0.")
 (depends
  (ocaml
   (>= 4.14))
  bytream
  dune)
 (tags (rpm)))
