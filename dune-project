(lang dune 3.16)

(name rpmfile)

(version 0.3.0)

(generate_opam_files true)

(source
 (github dx3mod/rpmfile))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name rpmfile)
 (synopsis "RPM package metadata reader")
 (depends
  (ocaml
   (> 4.14))
  dune)
 (tags
  (rpm parser rpmfile)))

(package
 (name rpmfile_unix)
 (synopsis "RPM package metadata reader (powered by Angstrom)")
 (depends
  (ocaml
   (> 4.14))
  dune
  rpmfile
  (angstrom
   (>= 0.15))
  (angstrom-unix
   (>= 0.15))
  (alcotest :with-test))
 (tags
  (rpm parser rpmfile)))

(package
 (name rpmfile_eio)
 (synopsis "RPM package metadata reader (powered by Eio)")
 (depends))
