create or replace package evt_api_external_pkg as

procedure get_events(
    i_procedure_name    in      com_api_type_pkg.t_oracle_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null  
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_status            in      com_api_type_pkg.t_dict_value       default EVT_API_CONST_PKG.EVENT_STATUS_READY
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , o_row_count            out  com_api_type_pkg.t_long_id
  , o_ref_cursor           out  com_api_type_pkg.t_ref_cur
);

end evt_api_external_pkg;
/
