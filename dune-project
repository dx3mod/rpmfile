(lang dune 3.16)

(name rpmfile)

(version 0.4.0)

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
   (>= 4.14))
  dune)
 (tags
  (rpm parser rpmfile)))

(package
 (name rpmfile-unix)
 (synopsis "RPM package metadata reader (powered by Angstrom)")
 (depends
  (ocaml
   (>= 4.14))
  dune
  (rpmfile
   (>= 0.3.0))
  (angstrom
   (>= 0.15))
  (angstrom-unix
   (>= 0.15))
  (alcotest :with-test))
 (tags
  (rpm parser rpmfile)))

(package
 (name rpmfile-eio)
 (synopsis "RPM package metadata reader (powered by Eio)")
 (depends
  (ocaml
   (> 5.1))
  dune
  (rpmfile
   (>= 0.3.0))
  (eio
   (>= 1.1))
  (alcotest :with-test)
  (eio_main :with-test))
 (tags
  (rpm parser rpmfile)))

(package
 (name rpmfile-cli)
 (synopsis "CLI utility for reading RPM package information (like rpm -qi)")
 (depends
  (ocaml
   (> 5.1))
  dune
  (eio_main
   (>= 1.1))
  rpmfile-eio)
 (tags
  (rpm parser rpmfile)))
