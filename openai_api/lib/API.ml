open Cohttp

let api_key = ref ""

let set_api_key key = api_key := key

let openai_api_scheme = "https"

let openai_api_host = "api.openai.com"

let authorization_header () =
  Header.add_authorization (Header.init ())
    (Auth.credential_of_string (Format.sprintf "Bearer %s" !api_key))
