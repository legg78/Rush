create or replace package pos_prc_batch_pkg as

procedure load_pos_batch(
    i_import_clear_pan  in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_session_id        in     com_api_type_pkg.t_long_id    default null
);

end;
/