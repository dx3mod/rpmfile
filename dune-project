(lang dune 3.16)

(name rpmfile)

(generate_opam_files true)

(source
 (github dx3mod/rpmfile))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name rpmfile)
 (synopsis "A RPM package metadata parser")
 (description "A RPM(v3) package metadata parser powered by Angstrom")
 (depends
  ocaml
  dune
  angstrom
  (alcotest :with-test))
 (tags
  (rpm parser)))
