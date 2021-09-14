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

val clear_engines : unit -> unit

val list_engines : unit -> engine_info Seq.t

val fetch_all : unit -> unit

val fetch : string -> engine_info option
