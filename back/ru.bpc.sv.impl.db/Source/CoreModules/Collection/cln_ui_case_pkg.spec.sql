create or replace package cln_ui_case_pkg is

procedure add_case(
    o_id                    out com_api_type_pkg.t_long_id
  , o_seqnum                out com_api_type_pkg.t_seqnum
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_split_hash         in     com_api_type_pkg.t_short_id      default null
  , i_case_number        in     com_api_type_pkg.t_name
  , i_creation_date      in     date                             default null
  , i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_status             in     com_api_type_pkg.t_dict_value    default null
  , i_resolution         in     com_api_type_pkg.t_dict_value    default null
);

procedure modify_case(
    i_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum            in out com_api_type_pkg.t_seqnum
  , i_status             in     com_api_type_pkg.t_dict_value
  , i_resolution         in     com_api_type_pkg.t_dict_value
);

procedure assign_user(
    i_case_id            in     com_api_type_pkg.t_long_id
  , i_user_id            in     com_api_type_pkg.t_long_id
  , i_comments           in     com_api_type_pkg.t_full_desc
);

end cln_ui_case_pkg;
/
