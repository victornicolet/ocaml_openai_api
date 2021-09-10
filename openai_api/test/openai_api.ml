open Openai_api.Core

let () =
  set_api_key (Sys.getenv "OPENAI_API_KEY");
  let engines = list_engines () in
  print_endline engines
