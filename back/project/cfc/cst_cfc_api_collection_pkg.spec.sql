create or replace package cst_cfc_api_collection_pkg as

procedure process(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_agent_id                  in  com_api_type_pkg.t_agent_id
  , i_lang                      in  com_api_type_pkg.t_dict_value
  , i_cust_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_cacc_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_payd_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_addr_evt_type_array_id    in  com_api_type_pkg.t_short_id
  , i_refd_evt_type_array_id    in  com_api_type_pkg.t_short_id
);

procedure mark_unprocess_event(
    i_procedure_name            in com_api_type_pkg.t_name
);

end cst_cfc_api_collection_pkg;
/
