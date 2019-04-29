create or replace package cln_ui_stage_pkg is

procedure add(
    o_id            out com_api_type_pkg.t_short_id
  , o_seqnum        out com_api_type_pkg.t_tiny_id
  , i_status     in     com_api_type_pkg.t_dict_value
  , i_resolution in     com_api_type_pkg.t_dict_value
);

procedure modify(    
    i_id         in     com_api_type_pkg.t_short_id
  , io_seqnum    in out com_api_type_pkg.t_tiny_id
  , i_status     in     com_api_type_pkg.t_dict_value
  , i_resolution in     com_api_type_pkg.t_dict_value
);

procedure remove(    
    i_id         in     com_api_type_pkg.t_short_id
);

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_status            in    com_api_type_pkg.t_dict_value
  , i_resolution        in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null
);

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_reason_code       in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null  
);

end cln_ui_stage_pkg;
/
