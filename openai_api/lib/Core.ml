open Lwt
open Cohttp
open Cohttp_lwt_unix

let api_key = ref ""

let set_api_key key = api_key := key

let openai_api_scheme = "https"

let openai_api_host = "api.openai.com"

let v1_engines = Uri.make ~scheme:openai_api_scheme ~host:openai_api_host ~path:"/v1/engines" ()

let authorization_header () =
  Header.add_authorization (Header.init ())
    (Auth.credential_of_string (Format.sprintf "Bearer %s" !api_key))

let list_engines () =
  let engines =
    Client.get ~headers:(authorization_header ()) v1_engines >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    Printf.printf "Response code: %d\n" code;
    Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    Printf.printf "Body of length: %d\n" (String.length body);
    body
  in
  Lwt_main.run engines
