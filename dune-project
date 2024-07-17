(lang dune 3.16)

(name rpmfile)

(version 0.1.0)

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
  "A library for reading metadata from RPM packages . Built as an Angstrom parser to support any use case")
 (depends
  ocaml
  dune
  angstrom
  (alcotest :with-test))
 (tags
  (rpm parser)))
