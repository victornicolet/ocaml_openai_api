open Openai_api

let () =
  API.set_api_key (Sys.getenv "OPENAI_API_KEY");
  Engines.fetch_all ();
  let engines = Engines.list_engines () in
  let f engine =
    Engines.(
      Format.printf "Engine %s - Ready? %s@." engine.ei_id (if engine.ei_ready then "yes" else "no"))
  in
  Seq.iter f engines;
  match Engines.fetch "davinci" with
  | Some davinci_engine ->
      Format.printf
        (if davinci_engine.ei_ready then "Davinci is ready.@." else "Davinci not ready.@.")
  | None -> Format.eprintf "Davinci not found."
