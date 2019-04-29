create or replace package trc_prc_log_pkg as

procedure process(
    i_entity_type         in      com_api_type_pkg.t_dict_value
    , i_object_id         in      com_api_type_pkg.t_long_id
    , i_start_date        in      timestamp
    , i_end_date          in      timestamp
);

procedure unload_audit_log(
    i_start_date          in      timestamp
    , i_end_date          in      timestamp
    , i_session_id        in      com_api_type_pkg.t_long_id   
    , i_user_id           in      com_api_type_pkg.t_short_id
);

end;
/
