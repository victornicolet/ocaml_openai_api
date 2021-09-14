open API
open Lwt
open Cohttp
open Cohttp_lwt_unix

type engine_info = {
  ei_id : string;
  ei_created : string option;
  ei_owner : string;
  ei_permissions : string option;
  ei_ready : bool;
  ei_ready_replicas : bool option;
  ei_replicas : string option;
  ei_json_repr : Yojson.Basic.t;
}

let v1_engines = Uri.make ~scheme:openai_api_scheme ~host:openai_api_host ~path:"/v1/engines" ()

let v1_engine_retrieval id =
  Uri.make ~scheme:openai_api_scheme ~host:openai_api_host ~path:("/v1/engines/" ^ id) ()

let engines : (string, engine_info) Hashtbl.t = Hashtbl.create 5

let clear_engines () = Hashtbl.clear engines

let list_engines () : engine_info Seq.t = Hashtbl.to_seq_values engines

let parse_engine_json (assocs : (string * Yojson.Basic.t) list) : engine_info option =
  try
    let id =
      match List.assoc "id" assocs with
      | `String id -> id
      | _ -> failwith "engine should have at least an id."
    in
    let created = Option.map Yojson.Basic.to_string (List.assoc_opt "created" assocs) in
    let owner = Yojson.Basic.to_string (List.assoc "owner" assocs) in
    let permissions = Option.map Yojson.Basic.to_string (List.assoc_opt "permissions" assocs) in
    let ready = match List.assoc_opt "ready" assocs with Some (`Bool b) -> b | _ -> false in
    let ready_replicas =
      match List.assoc_opt "ready_replicas" assocs with Some (`Bool b) -> Some b | _ -> None
    in
    let replicas = Option.map Yojson.Basic.to_string (List.assoc_opt "replicas" assocs) in
    Some
      {
        ei_id = id;
        ei_created = created;
        ei_owner = owner;
        ei_permissions = permissions;
        ei_ready = ready;
        ei_ready_replicas = ready_replicas;
        ei_replicas = replicas;
        ei_json_repr = `Assoc assocs;
      }
  with Failure s ->
    Format.eprintf "Error : %s@." s;
    None

let add_engine_from_json (engine : Yojson.Basic.t) : unit =
  match engine with
  | `Assoc assocs -> (
      match parse_engine_json assocs with
      | Some engine -> Hashtbl.replace engines engine.ei_id engine
      | None -> ())
  | _ -> ()

let fetch_all () : unit =
  let engines =
    Client.get ~headers:(authorization_header ()) v1_engines >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    if Code.is_success code then body |> Cohttp_lwt.Body.to_string >|= fun body -> Some body
    else return None
  in
  match Lwt_main.run engines with
  | Some json_string -> (
      match Yojson.Basic.from_string json_string with
      | `Assoc [ ("object", `String "list"); ("data", `List engines) ] ->
          List.iter add_engine_from_json engines
      | _ -> Format.eprintf "Failed to parse engines json.@.")
  | None -> Format.eprintf "Failed to fetch engines.@."

let fetch (id : string) : engine_info option =
  let engine_info =
    Client.get ~headers:(authorization_header ()) (v1_engine_retrieval id) >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    if Code.is_success code then body |> Cohttp_lwt.Body.to_string >|= fun body -> Some body
    else return None
  in
  match Lwt_main.run engine_info with
  | Some json_string -> (
      match Yojson.Basic.from_string json_string with
      | `Assoc assocs -> (
          match parse_engine_json assocs with
          | Some engine ->
              Hashtbl.replace engines engine.ei_id engine;
              Some engine
          | None ->
              Format.eprintf "Failed to parse engine json.@.";
              None)
      | _ ->
          Format.eprintf "Failed to parse engines json.@.";
          None)
  | None ->
      Format.eprintf "Failed to fetch engines.@.";
      None
