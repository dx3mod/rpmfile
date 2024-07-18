(lang dune 3.16)

(name rpmfile)

(version 0.2.0)

(generate_opam_files true)

(source
 (github dx3mod/rpmfile))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name rpmfile)
 (synopsis "RPM package metadata reader")
 (description
  "A library for reading metadata from RPM packages, providing an Angstrom parser and a simple interface for accessing values")
 (depends
  (ocaml
   (> 4.14))
  dune
  (angstrom
   (>= 0.15))
  (alcotest :with-test))
 (tags
  (rpm parser)))
