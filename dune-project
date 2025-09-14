(lang dune 3.16)

(name rpmfile)

(version 0.8.0)

(generate_opam_files true)

(source
 (github dx3mod/rpmfile))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name rpmfile)
 (synopsis "RPM package reader")
 (depends
  (ocaml
   (>= 4.14))
  (angstrom
   (>= 0.15))
  dune)
 (tags (rpm)))
