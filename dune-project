(lang dune 2.9)

(generate_opam_files true)

(package
 (name "openai_api")
 (synopsis "A wrapper around OpenAI's API in OCaml.")
 (description "A wrapper around OpenAI's API in OCaml.")
 (license "MIT")
 (authors "Victor Nicolet")
 (bug_reports "https://www.github.com/victornicolet/ocaml_openai_api/issues")
 (homepage "https://www.github.com/victornicolet/ocaml_openai_api/issues")
 (depends
  ("cohttp"
   (>= "4.0.0"))
  ("cohttp-lwt-unix"
   (>= "4.0.0"))
  ("tls"
   (>= "0.14.0"))))
